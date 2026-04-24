#!/bin/bash
# Game-profile hook for Core Keeper Dedicated Server (App ID: 1621690)
#
# GAME_LAUNCH_CMD is auto-set to: ./CoreKeeperServer
#
# Core Keeper requires a virtual framebuffer (Xvfb) on first run.
# Xvfb is started here as root before the server process launches.
#
# Extra packages required beyond the base image:

export GAME_LAUNCH_CMD="${GAME_LAUNCH_CMD:-./CoreKeeperServer}"

if ! dpkg -s xvfb >/dev/null 2>&1; then
    apt-get update -qq
    apt-get install -y --no-install-recommends \
        lib32stdc++6 \
        xvfb \
        screen \
        libxi6
    rm -rf /var/lib/apt/lists/*
fi

# Start a virtual display so the server can initialise its graphics subsystem
if ! pgrep -x Xvfb >/dev/null 2>&1; then
    Xvfb :99 -screen 0 640x480x24 &
fi
export DISPLAY=:99
