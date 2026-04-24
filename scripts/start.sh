#!/bin/bash
echo "--- Remapping PUID:${PUID} / PGID:${PGID} ---"
groupmod -g "${PGID}" steam 2>/dev/null ||:
usermod -u "${PUID}" -g "${PGID}" steam

echo "--- Fixing ownership of data dirs ---"
chown -R "${PUID}:${PGID}" "${STEAMCMD_DIR}" "${SERVER_DIR}"

# Game-profile hook: /opt/custom/<GAME_ID>.sh installs game-specific packages.
# If not present locally, attempt to download from the repository.
if [ -n "${GAME_ID}" ]; then
    _profile="/opt/custom/${GAME_ID}.sh"
    if [ ! -f "${_profile}" ]; then
        _url="https://raw.githubusercontent.com/Lynkes/docker-steamcmd-server/main/scripts/games/${GAME_ID}.sh"
        echo "--- Downloading game profile for ${GAME_ID} ---"
        mkdir -p /opt/custom
        wget -q -O "${_profile}" "${_url}" 2>/dev/null || rm -f "${_profile}"
    fi
    if [ -f "${_profile}" ]; then
        echo "--- Running game profile: ${_profile} ---"
        chmod +x "${_profile}"
        # shellcheck disable=SC1090
        . "${_profile}" || echo "--- Game profile hook exited with error ---"
    else
        echo "--- No game profile found for GAME_ID=${GAME_ID} (skipping) ---"
    fi
fi

# User hook: /opt/custom/user.sh (or /opt/scripts/user.sh as fallback).
# Runs after the game-profile hook so it can override or extend it.
for _hook in /opt/custom/user.sh /opt/scripts/user.sh; do
    if [ -f "${_hook}" ]; then
        echo "--- Running user hook: ${_hook} ---"
        chmod +x "${_hook}"
        # shellcheck disable=SC1090
        . "${_hook}" || echo "--- User hook exited with error ---"
        break
    fi
done

_term() {
    echo "--- SIGTERM received, forwarding to server process ---"
    kill -TERM "${child}" 2>/dev/null
    wait "${child}"
}
trap _term SIGTERM

echo "--- Starting server ---"
su steam -c "/opt/scripts/start-server.sh" &
child=$!
wait "${child}"
