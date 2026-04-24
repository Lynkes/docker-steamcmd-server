#!/bin/bash
# user.sh — custom hook executed as root before the server starts
#
# Drop this file into /opt/custom/ on a host-mounted volume:
#   --volume /your/host/custom:/opt/custom
#
# Execution order:
#   1. Game profile hook  (/opt/custom/<GAME_ID>.sh) — auto-downloaded from GitHub;
#      installs runtime deps and sets GAME_LAUNCH_CMD for known App IDs.
#   2. This script        (/opt/custom/user.sh)       — your custom logic on top.
#
# Both hooks are sourced (. hook.sh), so 'export' propagates to the server process.
# A non-zero exit is logged but does not stop the container from starting.

# ─── Example 1: Install extra packages ──────────────────────────────────────
# Note: known games (see scripts/games/) already install their own deps.
# Use this only for packages not covered by the game profile.
# apt-get update -qq && apt-get install -y --no-install-recommends libsdl2-2.0-0

# ─── Example 2: Install multiple packages ────────────────────────────────────
# apt-get update -qq && apt-get install -y --no-install-recommends \
#     lib32gcc-s1 \
#     libsdl2-2.0-0 \
#     curl

# ─── Example 3: Write a game config file before the server reads it ──────────
# Runs after the game profile, so SERVER_DIR and GAME_LAUNCH_CMD are already set.
# mkdir -p "${SERVER_DIR}/config"
# cat > "${SERVER_DIR}/config/server.cfg" << 'EOF'
# hostname "My Server"
# sv_password ""
# rcon_password "changeme"
# EOF

# ─── Example 4: Download a mod or extra asset ────────────────────────────────
# curl -fsSL "https://example.com/mymod.zip" -o /tmp/mymod.zip
# unzip -qo /tmp/mymod.zip -d "${SERVER_DIR}/mods/"
# rm /tmp/mymod.zip

# ─── Example 5: Override an environment variable for this session ─────────────
# export GAME_PARAMS="${GAME_PARAMS} +sv_pure 0"

# ─── Add your active commands below this line ────────────────────────────────
