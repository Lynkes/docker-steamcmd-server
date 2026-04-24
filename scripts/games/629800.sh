#!/bin/bash
# Game-profile hook for Mordhau Dedicated Server (App ID: 629800)
#
# GAME_LAUNCH_CMD is auto-set to: ./MordhauServer.sh
#
# Mordhau's binary links against many X11 and system UI libraries.
# NOTE: libgconf-2-4 was removed in Debian Bookworm. If Mordhau fails to
# start with a missing libgconf error, the binary may require Bullseye.
#
# Extra packages required beyond the base image:

export GAME_LAUNCH_CMD="${GAME_LAUNCH_CMD:-./MordhauServer.sh}"

if ! dpkg -s libcurl4 >/dev/null 2>&1; then
apt-get update -qq
apt-get install -y --no-install-recommends \
    libcurl4 \
    libfontconfig1 \
    libpangocairo-1.0-0 \
    libnss3 \
    libxi6 \
    libxcursor1 \
    libxss1 \
    libxcomposite1 \
    libasound2 \
    libxdamage1 \
    libxtst6 \
    libatk1.0-0 \
    libxrandr2 \
    iputils-ping \
    libcurl3-gnutls
    rm -rf /var/lib/apt/lists/*
fi
