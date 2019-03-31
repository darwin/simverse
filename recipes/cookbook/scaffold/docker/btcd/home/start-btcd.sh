#!/usr/bin/env bash

source lib/init.sh

mkdir -p "/root/.btcd"
cp "/root/seed-btcd.conf" "/root/.btcd/btcd.conf"

# we keep one shared rpc cert for all btcd nodes
PARAMS="--rpccert=/certs/rpc.cert --rpckey=/certs/rpc.key"

# optional parameters
DEBUG=${DEBUG}
NETWORK=${NETWORK}
RPC_USER=${RPC_USER}
RPC_PASS=${RPC_PASS}
BTCD_MINING_ADDR=${BTCD_MINING_ADDR}
BTCD_LISTEN=${BTCD_LISTEN}
BTCD_RPC_LISTEN=${BTCD_RPC_LISTEN}
BTCD_EXTRA_PARAMS=${BTCD_EXTRA_PARAMS}

if [[ -n "$NETWORK" ]]; then
  PARAMS+=" --$NETWORK"
fi

if [[ -n "$DEBUG" ]]; then
  PARAMS+=" --debuglevel=\"$DEBUG\""
fi

if [[ -n "$BTCD_LISTEN" ]]; then
  PARAMS+=" --listen=\"$BTCD_LISTEN\""
fi

if [[ -n "$BTCD_RPC_LISTEN" ]]; then
  PARAMS+=" --rpclisten=\"$BTCD_RPC_LISTEN\""
fi

if [[ -n "$RPC_USER" ]]; then
  PARAMS+=" --rpcuser=\"$RPC_USER\""
fi

if [[ -n "$RPC_PASS" ]]; then
  PARAMS+=" --rpcpass=\"$RPC_PASS\""
fi

if [[ -n "$BTCD_MINING_ADDR" ]]; then
  PARAMS+=" --miningaddr=$BTCD_MINING_ADDR"
fi

if [[ ! "$@" = *"--droptxindex"* ]]; then
  PARAMS+=" --txindex"
fi

PARAMS+=" $@"

set -x
exec btcd ${PARAMS} ${BTCD_EXTRA_PARAMS}
