#!/usr/bin/env bash

source lib/init.sh
source lib/utils.sh

CONTAINER_NAME=${CONTAINER_NAME:?required}

# TODO: figure a way how to talk to bitcoin node to determine block height
cmd="[[ 400 < \$(lightning-cli.sh getinfo | jq .blockheight) ]]"
wait_for "$CONTAINER_NAME to sync" "$cmd"

signal_service_ready