#!/bin/bash
# Game-profile hook for Palworld Dedicated Server (App ID: 2394010)
#
# GAME_LAUNCH_CMD is auto-set to: ./PalServer.sh
#
# Extra packages required beyond the base image:

export GAME_LAUNCH_CMD="${GAME_LAUNCH_CMD:-./PalServer.sh}"

if ! dpkg -s lib32stdc++6 >/dev/null 2>&1; then
    apt-get update -qq
    apt-get install -y --no-install-recommends \
        lib32stdc++6 \
        xdg-user-dirs
    rm -rf /var/lib/apt/lists/*
fi
