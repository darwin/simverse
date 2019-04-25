#!/usr/bin/env bash

source lib/init.sh

RPC_USER=${RPC_USER}
RPC_PASS=${RPC_PASS}
BITCOINCLI_EXTRA_PARAMS=${BITCOINCLI_EXTRA_PARAMS}
BITCOIN_RPC_PORT=${BITCOIN_RPC_PORT}

PARAMS=""
PARAMS+=" -rpcport=${BITCOIN_RPC_PORT}"

if [[ -n "$RPC_USER" ]]; then
  PARAMS+=" -rpcuser=$RPC_USER"
  PARAMS+=" -rpcpassword=$RPC_PASS"
fi

#set -x
exec bitcoin-cli ${PARAMS} ${BITCOINCLI_EXTRA_PARAMS} "$@"
