#!/usr/bin/env bash

source lib/init.sh

mkdir -p "$LIGHTNINGD_DATA/regtest"
cp "seed-config" "$LIGHTNINGD_DATA/regtest/config"

# optional parameters
RPC_USER=${RPC_USER}
RPC_PASS=${RPC_PASS}
DEBUG=${DEBUG}
LIGHTNING_ALIAS=${LIGHTNING_ALIAS} # <service-name>
LIGHTNING_BACKEND=${LIGHTNING_BACKEND}
LIGHTNING_P2P_BIND=${LIGHTNING_P2P_BIND} # 0.0.0.0
LIGHTNING_P2P_PORT=${LIGHTNING_P2P_PORT} # 9735
LIGHTNING_RPC_BIND=${LIGHTNING_RPC_BIND} # 0.0.0.0
LIGHTNING_RPC_PORT=${LIGHTNING_RPC_PORT} # 10009
LIGHTNING_BITCOIN_RPC_HOST=${LIGHTNING_BITCOIN_RPC_HOST}
BITCOIN_RPC_PORT=${BITCOIN_RPC_PORT}
LIGHTNINGD_EXTRA_PARAMS=${LIGHTNINGD_EXTRA_PARAMS}

if [[ "$LIGHTNING_BACKEND" != "bitcoind" ]]; then
  echo "c-lightning nodes support only bitcoind backend, you passed '$LIGHTNING_BACKEND'"
  exit 1
fi

PARAMS=""

PARAMS=" --network regtest"

if [[ -n "$LIGHTNING_BITCOIN_RPC_HOST" ]]; then
  PARAMS+=" --bitcoin-rpcconnect $LIGHTNING_BITCOIN_RPC_HOST"
fi

if [[ -n "$BITCOIN_RPC_PORT" ]]; then
  PARAMS+=" --bitcoin-rpcport $BITCOIN_RPC_PORT"
fi

if [[ -n "$RPC_USER" ]]; then
  PARAMS+=" --bitcoin-rpcuser $RPC_USER"
  PARAMS+=" --bitcoin-rpcpassword $RPC_PASS"
fi

if [[ -n "$LIGHTNING_ALIAS" ]]; then
  PARAMS+=" --alias=$LIGHTNING_ALIAS"
fi

if [[ -n "$LIGHTNING_P2P_BIND" ]]; then
  PARAMS+=" --bind-addr $LIGHTNING_P2P_BIND:$LIGHTNING_P2P_PORT"
fi

if [[ -n "$DEBUG" ]]; then
  PARAMS+=" --log-level=$DEBUG"
fi

PARAMS+=" --disable-dns"
PARAMS+=" --rpc-file=${LIGHTNINGD_RPC_DIR_SIMVERSE}/rpc-socket"

set -x
exec lightning-docker-entrypoint.sh ${PARAMS} ${LIGHTNINGD_EXTRA_PARAMS} "$@"
