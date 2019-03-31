#!/usr/bin/env bash

source lib/init.sh

BTCCTL_EXTRA_PARAMS=${BTCCTL_EXTRA_PARAMS}
NETWORK=${NETWORK:-simnet}
RPC_USER=${RPC_USER}
RPC_PASS=${RPC_PASS}

PARAMS="--rpccert=/certs/rpc.cert"

if [[ -n "$RPC_USER" ]]; then
  PARAMS+=" --rpcuser=\"$RPC_USER\""
fi

if [[ -n "$RPC_PASS" ]]; then
  PARAMS+=" --rpcpass=\"$RPC_PASS\""
fi

if [[ -n "$NETWORK" ]]; then
  PARAMS+=" --$NETWORK"
fi

PARAMS+=" $@"

#set -x
exec btcctl ${PARAMS} ${BTCCTL_EXTRA_PARAMS}
