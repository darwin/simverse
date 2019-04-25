#!/usr/bin/env bash

source lib/init.sh

cp "seed-btcd.conf" ".btcd/btcd.conf"

PARAMS=""

# optional parameters
DEBUG=${DEBUG}
RPC_USER=${RPC_USER}
RPC_PASS=${RPC_PASS}
FAUCET_ADDR=${FAUCET_ADDR}
BITCOIN_P2P_BIND=${BITCOIN_P2P_BIND}
BITCOIN_P2P_PORT=${BITCOIN_P2P_PORT}
BITCOIN_RPC_BIND=${BITCOIN_RPC_BIND}
BITCOIN_RPC_PORT=${BITCOIN_RPC_PORT}
BTCD_EXTRA_PARAMS=${BTCD_EXTRA_PARAMS}

PARAMS+=" --regtest"

if [[ -n "$DEBUG" ]]; then
  PARAMS+=" --debuglevel=$DEBUG"
fi

if [[ -n "$BITCOIN_P2P_BIND" ]]; then
  PARAMS+=" --listen=$BITCOIN_P2P_BIND:$BITCOIN_P2P_PORT"
fi

if [[ -n "$BITCOIN_RPC_BIND" ]]; then
  PARAMS+=" --rpclisten=$BITCOIN_RPC_BIND:$BITCOIN_RPC_PORT"
fi

if [[ -n "$RPC_USER" ]]; then
  PARAMS+=" --rpcuser=$RPC_USER"
  PARAMS+=" --rpcpass=$RPC_PASS"
fi

if [[ -n "$FAUCET_ADDR" ]]; then
  PARAMS+=" --miningaddr=$FAUCET_ADDR"
fi

if [[ ! "$@" = *"--droptxindex"* ]]; then
  PARAMS+=" --txindex"
fi

# we keep one shared rpc cert for all btcd nodes
PARAMS+=" --rpccert=/certs/rpc.cert"
PARAMS+=" --rpckey=/certs/rpc.key"

set -x
exec btcd ${PARAMS} ${BTCD_EXTRA_PARAMS} "$@"
