#!/usr/bin/env bash

. lib/utils.sh

# wait for bitcoin node to open its RPC interface
LIGHTNING_BITCOIN_RPC_HOST=${LIGHTNING_BITCOIN_RPC_HOST:?required}
BITCOIN_RPC_PORT=${BITCOIN_RPC_PORT:?required}
wait_for_socket "$BITCOIN_RPC_PORT" "$LIGHTNING_BITCOIN_RPC_HOST"

exec lightningd.sh