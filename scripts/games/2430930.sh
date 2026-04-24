#!/bin/bash
# Game-profile hook for ARK: Survival Ascended (App ID: 2430930)
#
# ASA has no native Linux binary. It runs under Wine (64-bit).
# GAME_LAUNCH_CMD is auto-set to:
#   xvfb-run --auto-servernum --server-args='-screen 0 640x480x24:32' wine64 ./ArkAscendedServer.exe
#
# ── Important: Windows build required ────────────────────────────────────────
# SteamCMD must download the Windows build. Add this to your steamcmd call in
# start-server.sh (or a derived image):
#   +@sSteamCmdForcePlatformType windows

export GAME_LAUNCH_CMD="${GAME_LAUNCH_CMD:-xvfb-run --auto-servernum --server-args='-screen 0 640x480x24:32' wine64 ./ArkAscendedServer.exe}"
export WINEARCH="${WINEARCH:-win64}"
export WINEPREFIX="${WINEPREFIX:-${SERVER_DIR}/WINE64}"

if dpkg -s winehq-stable >/dev/null 2>&1; then
    echo "--- Wine already installed, skipping ---"
else
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
        lib32stdc++6 \
        lib32z1
    rm -rf /var/lib/apt/lists/*
fi
