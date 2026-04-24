#!/bin/bash
# Game-profile hook for Rust Dedicated Server (App ID: 258550)
#
# GAME_LAUNCH_CMD is auto-set to: ./RustDedicated
#
# Extra packages required beyond the base image:

export GAME_LAUNCH_CMD="${GAME_LAUNCH_CMD:-./RustDedicated}"

if ! dpkg -s libsqlite3-0 >/dev/null 2>&1; then
    apt-get update -qq
    apt-get install -y --no-install-recommends \
        libsqlite3-0 \
        libgdiplus \
        unzip
    rm -rf /var/lib/apt/lists/*
fi
