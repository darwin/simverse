#!/usr/bin/env bash

source lib/init.sh

BTCCTL_EXTRA_PARAMS=${BTCCTL_EXTRA_PARAMS}
RPC_USER=${RPC_USER}
RPC_PASS=${RPC_PASS}

PARAMS=""

# note: this option was added by our patch, see patches/btcctl-regtest.patch
PARAMS+=" --regtest"

PARAMS+=" --rpccert=/certs/rpc.cert"

if [[ -n "$RPC_USER" ]]; then
  PARAMS+=" --rpcuser=\"$RPC_USER\""
  PARAMS+=" --rpcpass=\"$RPC_PASS\""
fi

PARAMS+=" $@"

#set -x
exec btcctl ${PARAMS} ${BTCCTL_EXTRA_PARAMS}
