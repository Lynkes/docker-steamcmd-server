#!/bin/bash

# Download SteamCMD if the directory was volume-mounted empty
if [ ! -f "${STEAMCMD_DIR}/steamcmd.sh" ]; then
    echo "--- SteamCMD not found, downloading ---"
    wget -qO /tmp/steamcmd.tar.gz \
        https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
    tar -C "${STEAMCMD_DIR}" -xzf /tmp/steamcmd.tar.gz
    rm /tmp/steamcmd.tar.gz
fi

echo "--- Updating SteamCMD ---"
"${STEAMCMD_DIR}/steamcmd.sh" +login anonymous +quit

echo "--- Installing/updating game (GAME_ID=${GAME_ID}${GAME_BRANCH:+ branch=${GAME_BRANCH}}) ---"
VALIDATE_FLAG=""
[ "${VALIDATE}" = "true" ] && VALIDATE_FLAG="validate"
_BRANCH_FLAG=""
[ -n "${GAME_BRANCH}" ] && _BRANCH_FLAG="-beta ${GAME_BRANCH}"

if [ -n "${USERNAME}" ]; then
    "${STEAMCMD_DIR}/steamcmd.sh" \
        +force_install_dir "${SERVER_DIR}" \
        +login "${USERNAME}" "${PASSWRD}" \
        +app_update "${GAME_ID}" ${_BRANCH_FLAG} ${VALIDATE_FLAG} \
        +quit
else
    "${STEAMCMD_DIR}/steamcmd.sh" \
        +force_install_dir "${SERVER_DIR}" \
        +login anonymous \
        +app_update "${GAME_ID}" ${_BRANCH_FLAG} ${VALIDATE_FLAG} \
        +quit
fi

echo "--- Scanning game files for runtime dependencies ---"

# Java: any .jar present means the server is JVM-based
if find "${SERVER_DIR}" -maxdepth 3 -name "*.jar" | grep -q .; then
    if ! command -v java > /dev/null 2>&1; then
        echo "--- Detected Java requirement (.jar files found); installing openjdk-21-jre-headless ---"
        apt-get update -qq && apt-get install -y --no-install-recommends openjdk-21-jre-headless
    fi
fi

# Missing shared libraries: run ldd on the launch binary and install any absent ones
_launch_bin="${SERVER_DIR}/$(echo "${GAME_LAUNCH_CMD}" | awk '{print $1}' | sed 's|^\./||')"
if [ -f "${_launch_bin}" ] && file "${_launch_bin}" | grep -q "ELF"; then
    _missing=$(ldd "${_launch_bin}" 2>/dev/null | awk '/not found/{print $1}' | sort -u)
    if [ -n "${_missing}" ]; then
        echo "--- Missing shared libraries detected: ${_missing} ---"
        echo "--- Running apt-file search to resolve packages (this may take a moment) ---"
        apt-get update -qq
        apt-get install -y --no-install-recommends apt-file > /dev/null 2>&1
        apt-file update -q > /dev/null 2>&1
        _pkgs=""
        for _lib in ${_missing}; do
            _pkg=$(apt-file search --package-only "${_lib}" 2>/dev/null | head -1)
            [ -n "${_pkg}" ] && _pkgs="${_pkgs} ${_pkg}"
        done
        if [ -n "${_pkgs}" ]; then
            echo "--- Installing:${_pkgs} ---"
            # shellcheck disable=SC2086
            apt-get install -y --no-install-recommends ${_pkgs}
        else
            echo "--- Could not auto-resolve packages for: ${_missing} ---"
            echo "--- Install them manually via a user.sh hook ---"
        fi
    fi
fi

if [ -z "${GAME_LAUNCH_CMD}" ]; then
    echo "--- Error: GAME_LAUNCH_CMD is not set. Set it to the server executable, e.g. './start-server.sh' ---"
    exit 1
fi

echo "--- Launching: ${GAME_LAUNCH_CMD} ${GAME_PARAMS} ${GAME_PARAMS_EXTRA} ---"
cd "${SERVER_DIR}"
# Word splitting on GAME_LAUNCH_CMD, GAME_PARAMS and GAME_PARAMS_EXTRA is intentional
# shellcheck disable=SC2086
exec ${GAME_LAUNCH_CMD} ${GAME_PARAMS} ${GAME_PARAMS_EXTRA}
