#!/usr/bin/env bash

source lib/init.sh
source lib/utils.sh

CONTAINER_NAME=${CONTAINER_NAME:?required}
CONTAINER_SERVICE_PORT=${CONTAINER_SERVICE_PORT:?required}
ECLAIR_BITCOIN_RPC_HOST=${ECLAIR_BITCOIN_RPC_HOST}

# shim for some wallet commands
case "$1" in
  # eclair uses bitcoind's wallet, we ask it to generate a new address for us
  newaddr)
    echo get-new-address | nc "$ECLAIR_BITCOIN_RPC_HOST" "$CONTAINER_SERVICE_PORT" | trim
    exit 0
    ;;
  walletbalance)
    echo get-wallet-balance | nc "$ECLAIR_BITCOIN_RPC_HOST" "$CONTAINER_SERVICE_PORT" | trim
    exit 0
    ;;
esac

ECLAIR_RPC_PORT=${ECLAIR_RPC_PORT} # 8080
RPC_PASS=${RPC_PASS}

PARAMS=""

if [[ -n "$ECLAIR_RPC_PORT" ]]; then
  PARAMS+=" -a http://localhost:${ECLAIR_RPC_PORT}"
fi

if [[ -n "$RPC_PASS" ]]; then
  PARAMS+=" -p \"${RPC_PASS}\""
fi

#set -x

# hack it to undo ansi colors added by jq in eclair-cli
exec eclair-cli ${PARAMS} "$@" | strip_ansi_colors
