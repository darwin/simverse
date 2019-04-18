#!/usr/bin/env bash

source lib/init.sh

cp "seed-lnd.conf" ".lnd/lnd.conf"

# optional parameters
RPC_USER=${RPC_USER}
RPC_PASS=${RPC_PASS}
DEBUG=${DEBUG}
LND_CHAIN=${LND_CHAIN} # bitcoin
LND_BACKEND=${LND_BACKEND} # btcd
LND_RPC_LISTEN=${LND_RPC_LISTEN} # 0.0.0.0
LND_RPC_HOST=${LND_RPC_HOST} # btcd
LND_LISTEN=${LND_LISTEN} # 0.0.0.0
LND_EXTRA_PARAMS=${LND_EXTRA_PARAMS}
NETWORK=regtest

PARAMS=""

if [[ -n "$LND_CHAIN" && -n "$NETWORK" ]]; then
  PARAMS+=" --$LND_CHAIN.active --$LND_CHAIN.$NETWORK --$LND_CHAIN.node=btcd"
fi

if [[ -n "$DEBUG" ]]; then
  PARAMS+=" --debuglevel=\"$DEBUG\""
fi

if [[ -n "$LND_BACKEND" && -n "$LND_RPC_HOST" ]]; then
  PARAMS+=" --$LND_BACKEND.rpchost=\"$LND_RPC_HOST\""
fi

if [[ -n "$LND_BACKEND" ]]; then
  PARAMS+=" --$LND_BACKEND.rpccert=/certs/rpc.cert"
fi

if [[ -n "$LND_BACKEND" && -n "$RPC_USER" ]]; then
  PARAMS+=" --$LND_BACKEND.rpcuser=\"$RPC_USER\""
fi

if [[ -n "$LND_BACKEND" && -n "$RPC_PASS" ]]; then
  PARAMS+=" --$LND_BACKEND.rpcpass=\"$RPC_PASS\""
fi

if [[ -n "$LND_RPC_LISTEN" ]]; then
  PARAMS+=" --rpclisten=\"$LND_RPC_LISTEN\""
fi

if [[ -n "$LND_LISTEN" ]]; then
  PARAMS+=" --listen=\"$LND_LISTEN\""
fi

PARAMS+=" --noseedbackup"

PARAMS+=" $@"

set -x
exec lnd ${PARAMS} ${LND_EXTRA_PARAMS}
