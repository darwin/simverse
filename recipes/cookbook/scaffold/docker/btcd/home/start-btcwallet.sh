#!/usr/bin/env bash

source lib/init.sh

cp "seed-btcwallet.conf" ".btcwallet/btcwallet.conf"

PARAMS=""

# note we patch btcwallet's simnet mode to effectively run in regtest mode
# see patches/simnet-as-regtest.patch
# see https://github.com/btcsuite/btcwallet/issues/506
PARAMS+=" --simnet"

PARAMS+=" --appdata=$(pwd -P)/.btcwallet"

# we keep one shared rpc cert for all btcd nodes
PARAMS+=" --cafile=/certs/rpc.cert"
PARAMS+=" --rpccert=/certs/rpc.cert"
PARAMS+=" --rpckey=/certs/rpc.key"

# optional parameters
BTCWALLET_EXTRA_PARAMS=${BTCWALLET_EXTRA_PARAMS}
BTCWALLET_RPC_BIND=${BTCWALLET_RPC_BIND}
BTCWALLET_RPC_PORT=${BTCWALLET_RPC_PORT}
RPC_USER=${RPC_USER}
RPC_PASS=${RPC_PASS}
BTCWALLET_USER=${BTCWALLET_USER}
BTCWALLET_PASS=${BTCWALLET_PASS}
DEBUG=${DEBUG}

if [[ -n "$DEBUG" ]]; then
  PARAMS+=" --debuglevel=$DEBUG"
fi

if [[ -n "$BTCWALLET_RPC_BIND" ]]; then
  PARAMS+=" --rpclisten=$BTCWALLET_RPC_BIND:$BTCWALLET_RPC_PORT"
fi

if [[ -n "$RPC_USER" ]]; then
  PARAMS+=" --btcdusername=$RPC_USER"
  if [[ -z "$BTCWALLET_USER" ]]; then
    BTCWALLET_USER="$RPC_USER"
  fi
fi

if [[ -n "$RPC_PASS" ]]; then
  PARAMS+=" --btcdpassword=$RPC_PASS"
  if [[ -z "$BTCWALLET_PASS" ]]; then
    BTCWALLET_PASS="$RPC_PASS"
  fi
fi

if [[ -n "$BTCWALLET_USER" ]]; then
  PARAMS+=" --username=$BTCWALLET_USER"
  PARAMS+=" --password=$BTCWALLET_PASS"
fi

PARAMS+=" --createtemp"
PARAMS+=" $@"

set -x
exec btcwallet ${PARAMS} ${BTCWALLET_EXTRA_PARAMS}
