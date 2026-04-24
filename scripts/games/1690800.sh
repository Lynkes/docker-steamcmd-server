#!/bin/bash
# Game-profile hook for Satisfactory Dedicated Server (App ID: 1690800)
#
# GAME_LAUNCH_CMD is auto-set to: ./FactoryServer.sh
#
# Extra packages required beyond the base image:

export GAME_LAUNCH_CMD="${GAME_LAUNCH_CMD:-./FactoryServer.sh}"

if ! dpkg -s xdg-user-dirs >/dev/null 2>&1; then
    apt-get update -qq
    apt-get install -y --no-install-recommends xdg-user-dirs
    rm -rf /var/lib/apt/lists/*
fi
