#!/bin/bash
# Game-profile hook for American Truck Simulator Dedicated Server (App ID: 2239530)
#
# GAME_LAUNCH_CMD is auto-set to: ./bin/linux_x64/amtrucks_server
#
# ATS shares the same engine as ETS2 and requires the same extra dependencies.
#
# Extra packages required beyond the base image:

export GAME_LAUNCH_CMD="${GAME_LAUNCH_CMD:-./bin/linux_x64/amtrucks_server}"

if ! dpkg -s libatomic1 >/dev/null 2>&1; then
    apt-get update -qq
    apt-get install -y --no-install-recommends \
        lib32stdc++6 \
        libatomic1 \
        libx11-6
    rm -rf /var/lib/apt/lists/*
fi

# Third-party libs bundle (same source as ETS2) — marker in STEAMCMD_DIR
if [ ! -f "${STEAMCMD_DIR}/.ats_3rdparty_installed" ]; then
    wget -qO /tmp/libs.tar \
        https://github.com/ich777/docker-steamcmd-server/raw/ets2/libs/3rd_party_libs.tar
    tar -C /usr/lib/x86_64-linux-gnu/ -xf /tmp/libs.tar
    rm /tmp/libs.tar
    touch "${STEAMCMD_DIR}/.ats_3rdparty_installed"
fi
