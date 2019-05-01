#!/usr/bin/env bash

source lib/init.sh
source lib/utils.sh

CONTAINER_NAME=${CONTAINER_NAME:?required}
CONTAINER_SERVICE_PORT=${CONTAINER_SERVICE_PORT:?required}
LIGHTNING_BITCOIN_RPC_HOST=${LIGHTNING_BITCOIN_RPC_HOST}

cmd="[[ \$(echo get-chain-height | nc $LIGHTNING_BITCOIN_RPC_HOST $CONTAINER_SERVICE_PORT) == \$(lightning-cli.sh getinfo | jq .blockheight) ]]"
wait_for "$CONTAINER_NAME to sync" "$cmd"

signal_service_ready