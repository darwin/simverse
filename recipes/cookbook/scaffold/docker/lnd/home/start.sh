#!/usr/bin/env bash

source lib/init.sh
source lib/utils.sh

# wait for shared certificate creation
while [[ ! -f /certs/rpc.cert ]]; do sleep 1; done

# wait for bitcoin node to open its RPC interface
echo "Waiting for bitcoin node $LIGHTNING_BITCOIN_RPC_HOST to get ready..."
LND_BITCOIN_RPC_HOST=${LND_BITCOIN_RPC_HOST:?required}
SERVICE_READY_PORT=${SERVICE_READY_PORT:?required}
wait_for_socket "$SERVICE_READY_PORT" "$LND_BITCOIN_RPC_HOST"

exec lnd.sh