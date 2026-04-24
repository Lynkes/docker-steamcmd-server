#!/bin/bash
# Game-profile hook for V Rising Dedicated Server (App ID: 1604030)
#
# V Rising has no native Linux binary. It runs under Wine (64-bit).
# GAME_LAUNCH_CMD is auto-set to:
#   xvfb-run --auto-servernum --server-args='-screen 0 640x480x24:32' wine64 ./VRisingServer.exe
#
# ── Important: Windows build required ────────────────────────────────────────
# SteamCMD must download the Windows build. Add this to your steamcmd call in
# start-server.sh (or a derived image):
#   +@sSteamCmdForcePlatformType windows
#
# ── Wine installation ─────────────────────────────────────────────────────────
# This installs ~400 MB on every cold start. For production, bake Wine into a
# derived Dockerfile instead (see scripts/games/README.md).

export GAME_LAUNCH_CMD="${GAME_LAUNCH_CMD:-xvfb-run --auto-servernum --server-args='-screen 0 640x480x24:32' wine64 ./VRisingServer.exe}"
export WINEARCH="${WINEARCH:-win64}"
export WINEPREFIX="${WINEPREFIX:-${SERVER_DIR}/WINE64}"

if dpkg -s winehq-stable >/dev/null 2>&1; then
    echo "--- Wine already installed, skipping ---"
else
    # Add WineHQ stable repository for Debian Bookworm
    curl -fsSL https://dl.winehq.org/wine-builds/winehq.key \
        | gpg --dearmor -o /usr/share/keyrings/winehq.gpg
    echo "deb [arch=amd64,i386 signed-by=/usr/share/keyrings/winehq.gpg] \
https://dl.winehq.org/wine-builds/debian/ bookworm main" \
        > /etc/apt/sources.list.d/winehq.list

    apt-get update -qq
    apt-get install -y --no-install-recommends \
        winehq-stable \
        winbind \
        xvfb \
        xauth \
        lib32stdc++6 \
        lib32z1 \
        unzip \
        curl \
        jq
    rm -rf /var/lib/apt/lists/*
fi
