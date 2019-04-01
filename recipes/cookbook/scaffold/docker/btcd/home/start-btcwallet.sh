#!/usr/bin/env bash

source lib/init.sh

cp "seed-btcwallet.conf" ".btcwallet/btcwallet.conf"

PARAMS="--appdata=$(pwd -P)/.btcwallet"

# we keep one shared rpc cert for all btcd nodes
PARAMS+=" --cafile=/certs/rpc.cert --rpccert=/certs/rpc.cert --rpckey=/certs/rpc.key"

# optional parameters
BTCWALLET_EXTRA_PARAMS=${BTCWALLET_EXTRA_PARAMS}
BTCWALLET_RPC_LISTEN=${BTCWALLET_RPC_LISTEN}
RPC_USER=${RPC_USER}
RPC_PASS=${RPC_PASS}
BTCWALLET_USER=${BTCWALLET_USER}
BTCWALLET_PASS=${BTCWALLET_PASS}
DEBUG=${DEBUG}
NETWORK=${NETWORK}

if [[ -n "$NETWORK" ]]; then
  PARAMS+=" --$NETWORK"
fi

if [[ -n "$DEBUG" ]]; then
  PARAMS+=" --debuglevel=\"$DEBUG\""
fi

if [[ -n "$BTCWALLET_RPC_LISTEN" ]]; then
  PARAMS+=" --rpclisten=\"$BTCWALLET_RPC_LISTEN\""
fi

if [[ -n "$RPC_USER" ]]; then
  PARAMS+=" --btcdusername=\"$RPC_USER\""
  if [[ -z "$BTCWALLET_USER" ]]; then
    BTCWALLET_USER="$RPC_USER"
  fi
fi

if [[ -n "$RPC_PASS" ]]; then
  PARAMS+=" --btcdpassword=\"$RPC_PASS\""
  if [[ -z "$BTCWALLET_PASS" ]]; then
    BTCWALLET_PASS="$RPC_PASS"
  fi
fi

if [[ -n "$BTCWALLET_USER" ]]; then
  PARAMS+=" --username=\"$BTCWALLET_USER\""
fi

if [[ -n "$BTCWALLET_PASS" ]]; then
  PARAMS+=" --password=\"$BTCWALLET_PASS\""
fi

PARAMS+=" --createtemp"
PARAMS+=" $@"

set -x
exec btcwallet ${PARAMS} ${BTCWALLET_EXTRA_PARAMS}
