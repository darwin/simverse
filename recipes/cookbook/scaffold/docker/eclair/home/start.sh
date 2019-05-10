#!/usr/bin/env bash

source lib/init.sh
source lib/utils.sh

# wait for bitcoin node to open its RPC interface
ECLAIR_BITCOIN_RPC_HOST=${ECLAIR_BITCOIN_RPC_HOST:?required}
SERVICE_READY_PORT=${SERVICE_READY_PORT:?required}
echo "Waiting for bitcoin node $ECLAIR_BITCOIN_RPC_HOST to get ready..."
wait_for_socket "$SERVICE_READY_PORT" "$ECLAIR_BITCOIN_RPC_HOST"

get-ready.sh &

exec eclair.sh