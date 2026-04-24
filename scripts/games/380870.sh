#!/bin/bash
# Game-profile hook for Project Zomboid (App ID: 380870)
#
# Project Zomboid bundles its own JRE and a launcher JSON that controls JVM args.
# Key file: ${SERVER_DIR}/ProjectZomboid64.json
#
# ── Configurable env vars ──────────────────────────────────────────────────────
#   PZ_MAX_RAM   Max JVM heap (default: 8g). Patches -Xmx in ProjectZomboid64.json.
#                Example: --env PZ_MAX_RAM=16g
#
#   ADMIN_PWD    Server admin password. PZ will hang on first start without it.
#                If unset, a random password is generated and printed to the logs.

export GAME_LAUNCH_CMD="${GAME_LAUNCH_CMD:-/opt/scripts/pz-launch.sh}"

# Use the JRE bundled with the game instead of a system-wide install
export PATH="${SERVER_DIR}/jre64/bin:${PATH}"
export LD_LIBRARY_PATH="${SERVER_DIR}/linux64:${SERVER_DIR}/natives:${SERVER_DIR}:${SERVER_DIR}/jre64/lib/amd64:${LD_LIBRARY_PATH:-}"

# Default JVM heap — matches the upstream ProjectZomboid64.json default
export PZ_MAX_RAM="${PZ_MAX_RAM:-8g}"

# Ensure ADMIN_PWD is always set — PZ will hang on first start without it
if [ -z "${ADMIN_PWD}" ]; then
    ADMIN_PWD="$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 16)"
    echo "--- ADMIN_PWD not set; generated random admin password: ${ADMIN_PWD} ---"
    echo "--- Set --env ADMIN_PWD=<password> to use your own ---"
    export ADMIN_PWD
fi

# Inject -adminpassword into GAME_PARAMS so PZ never prompts interactively
export GAME_PARAMS="-adminpassword ${ADMIN_PWD}${GAME_PARAMS:+ ${GAME_PARAMS}}"

# Write a launch wrapper that patches ProjectZomboid64.json before every start.
# The JSON is written by steamcmd at install time (after this hook runs), so
# patching must happen at launch time rather than here.
cat > /opt/scripts/pz-launch.sh << 'WRAPPER'
#!/bin/bash
# Patch JVM args in ProjectZomboid64.json before each start
_json="${SERVER_DIR}/ProjectZomboid64.json"
if [ -f "${_json}" ]; then
    # Update max heap size (-Xmx)
    sed -i "s/-Xmx[0-9][0-9]*[gGmMkK]*/-Xmx${PZ_MAX_RAM}/" "${_json}"
fi
exec "${SERVER_DIR}/ProjectZomboid64" "$@"
WRAPPER
chmod +x /opt/scripts/pz-launch.sh
