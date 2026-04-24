#!/bin/bash
# Game-profile hook for Necesse Dedicated Server (App ID: 1169370)
#
# GAME_LAUNCH_CMD is auto-set to: ./Necesse
#
# No extra packages required beyond the base image.

export GAME_LAUNCH_CMD="${GAME_LAUNCH_CMD:-./Necesse}"
