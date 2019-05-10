#!/usr/bin/env bash

source lib/init.sh
source lib/utils.sh

CONTAINER_NAME=${CONTAINER_NAME:?required}
CONTAINER_SERVICE_PORT=${CONTAINER_SERVICE_PORT:?required}
ECLAIR_BITCOIN_RPC_HOST=${ECLAIR_BITCOIN_RPC_HOST}

cmd="[[ \$(echo get-chain-height | nc $ECLAIR_BITCOIN_RPC_HOST $CONTAINER_SERVICE_PORT) == \$(eclair-cli.sh getinfo | jq .blockHeight) ]]"
wait_for "$CONTAINER_NAME to sync" "$cmd"

signal_service_ready