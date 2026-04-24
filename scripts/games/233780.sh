#!/bin/bash
# Game-profile hook for Arma 3 Dedicated Server (App ID: 233780)
#
# Arma 3 requires a Steam account that owns the game (set USERNAME + PASSWRD).
# GAME_LAUNCH_CMD is auto-set to: ./arma3server_x64
#
# Extra packages required beyond the base image:

export GAME_LAUNCH_CMD="${GAME_LAUNCH_CMD:-./arma3server_x64}"

if ! dpkg -s lib32stdc++6 >/dev/null 2>&1; then
    apt-get update -qq
    apt-get install -y --no-install-recommends lib32stdc++6
    rm -rf /var/lib/apt/lists/*
fi
