#!/bin/bash
# Game-profile hook for Killing Floor 2 Dedicated Server (App ID: 232130)
#
# GAME_LAUNCH_CMD is auto-set to: ./Binaries/Win64/KFGameSteamServer.bin.x86_64
#
# Extra packages required beyond the base image:

export GAME_LAUNCH_CMD="${GAME_LAUNCH_CMD:-./Binaries/Win64/KFGameSteamServer.bin.x86_64}"

if ! dpkg -s curl >/dev/null 2>&1; then
    apt-get update -qq
    apt-get install -y --no-install-recommends curl
    rm -rf /var/lib/apt/lists/*
fi
