#!/usr/bin/env bash

source lib/init.sh

cp "seed-eclair.conf" ".eclair/eclair.conf"

# optional parameters
RPC_USER=${RPC_USER}
RPC_PASS=${RPC_PASS}
DEBUG=${DEBUG}
ECLAIR_ALIAS=${ECLAIR_ALIAS} # <service-name>
ECLAIR_BACKEND=${ECLAIR_BACKEND}
ECLAIR_P2P_BIND=${ECLAIR_P2P_BIND} # 0.0.0.0
ECLAIR_P2P_PORT=${ECLAIR_P2P_PORT} # 9735
ECLAIR_RPC_BIND=${ECLAIR_RPC_BIND} # 0.0.0.0
ECLAIR_RPC_PORT=${ECLAIR_RPC_PORT} # 8080
ECLAIR_BITCOIN_RPC_HOST=${ECLAIR_BITCOIN_RPC_HOST}
BITCOIN_RPC_PORT=${BITCOIN_RPC_PORT}
ECLAIR_EXTRA_PARAMS=${ECLAIR_EXTRA_PARAMS}
ZMQ_PUBRAWBLOCK_PORT=${ZMQ_PUBRAWBLOCK_PORT} # 28332
ZMQ_PUBRAWTX_PORT=${ZMQ_PUBRAWTX_PORT} # 28333
ZMQ_PUBRAWBLOCK="tcp://$ECLAIR_BITCOIN_RPC_HOST:$ZMQ_PUBRAWBLOCK_PORT"
ZMQ_PUBRAWTX="tcp://$ECLAIR_BITCOIN_RPC_HOST:$ZMQ_PUBRAWTX_PORT"


if [[ "$ECLAIR_BACKEND" != "bitcoind" ]]; then
  echo "eclair nodes support only bitcoind backend, you passed '$ECLAIR_BACKEND'"
  # note: in future eclair.watcher-type could support other bitcoin node implementations
  exit 1
fi

PARAMS=""

PARAMS+=" -Declair.chain=regtest"

if [[ -n "$ECLAIR_P2P_BIND" ]]; then
  PARAMS+=" -Declair.server.binding-ip=$ECLAIR_P2P_BIND"
fi

if [[ -n "$ECLAIR_P2P_PORT" ]]; then
  PARAMS+=" -Declair.server.port=$ECLAIR_P2P_PORT"
fi

if [[ -n "$ECLAIR_RPC_PORT" ]]; then
  PARAMS+=" -Declair.api.enabled=true"
  PARAMS+=" -Declair.api.port=$ECLAIR_RPC_PORT"
  PARAMS+=" -Declair.api.password=$RPC_PASS"
fi

if [[ -n "$ECLAIR_RPC_BIND" ]]; then
  PARAMS+=" -Declair.api.binding-ip=$ECLAIR_RPC_BIND"
fi

if [[ -n "$ECLAIR_BITCOIN_RPC_HOST" ]]; then
  PARAMS+=" -Declair.bitcoind.host=$ECLAIR_BITCOIN_RPC_HOST"
fi

if [[ -n "$BITCOIN_RPC_PORT" ]]; then
  PARAMS+=" -Declair.bitcoind.rpcport=$BITCOIN_RPC_PORT"
fi

if [[ -n "$RPC_USER" ]]; then
  PARAMS+=" -Declair.bitcoind.rpcuser=$RPC_USER"
  PARAMS+=" -Declair.bitcoind.rpcpassword=$RPC_PASS"
fi

if [[ -n "$ECLAIR_ALIAS" ]]; then
  PARAMS+=" -Declair.node-alias=$ECLAIR_ALIAS"
fi

if [[ -n "$ZMQ_PUBRAWBLOCK_PORT" ]]; then
  PARAMS+=" -Declair.bitcoind.zmqblock=$ZMQ_PUBRAWBLOCK"
fi

if [[ -n "$ZMQ_PUBRAWTX_PORT" ]]; then
  PARAMS+=" -Declair.bitcoind.zmqtx=$ZMQ_PUBRAWTX"
fi

#if [[ -n "$DEBUG" ]]; then
#  PARAMS+=" --log-level=$DEBUG"
#fi

PARAMS+=" -Declair.printToConsole=true"

set -x
exec java ${PARAMS} ${ECLAIR_EXTRA_PARAMS} "$@" -jar eclair-node.jar
