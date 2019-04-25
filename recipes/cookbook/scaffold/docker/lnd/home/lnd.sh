#!/usr/bin/env bash

source lib/init.sh

cp "seed-lnd.conf" ".lnd/lnd.conf"

# optional parameters
RPC_USER=${RPC_USER}
RPC_PASS=${RPC_PASS}
DEBUG=${DEBUG}
LND_CHAIN=${LND_CHAIN} # bitcoin
LND_BACKEND=${LND_BACKEND}
LND_P2P_BIND=${LND_P2P_BIND} # 0.0.0.0
LND_P2P_PORT=${LND_P2P_PORT} # 9735
LND_RPC_BIND=${LND_RPC_BIND} # 0.0.0.0
LND_RPC_PORT=${LND_RPC_PORT} # 10009
LND_REST_BIND=${LND_REST_BIND} # 0.0.0.0
LND_REST_PORT=${LND_REST_PORT} # 8080
LND_BITCOIN_RPC_HOST=${LND_BITCOIN_RPC_HOST}
BITCOIN_RPC_PORT=${BITCOIN_RPC_PORT}
LND_EXTRA_PARAMS=${LND_EXTRA_PARAMS}
ZMQ_PUBRAWBLOCK_PORT=${ZMQ_PUBRAWBLOCK_PORT} # 28332
ZMQ_PUBRAWTX_PORT=${ZMQ_PUBRAWTX_PORT} # 28333
ZMQ_PUBRAWBLOCK="tcp://$LND_BITCOIN_RPC_HOST:$ZMQ_PUBRAWBLOCK_PORT"
ZMQ_PUBRAWTX="tcp://$LND_BITCOIN_RPC_HOST:$ZMQ_PUBRAWTX_PORT"

PARAMS=""

if [[ -n "$LND_CHAIN" ]]; then
  PARAMS+=" --$LND_CHAIN.active"
  PARAMS+=" --$LND_CHAIN.regtest"
  PARAMS+=" --$LND_CHAIN.node=$LND_BACKEND"
fi

if [[ -n "$LND_BACKEND" && -n "$LND_BITCOIN_RPC_HOST" ]]; then
  PARAMS+=" --$LND_BACKEND.rpchost=$LND_BITCOIN_RPC_HOST:$BITCOIN_RPC_PORT"
fi

if [[ -n "$LND_BACKEND" && -n "$RPC_USER" ]]; then
  PARAMS+=" --$LND_BACKEND.rpcuser=$RPC_USER"
  PARAMS+=" --$LND_BACKEND.rpcpass=$RPC_PASS"
fi

if [[ "$LND_BACKEND" == "btcd" ]]; then
  PARAMS+=" --btcd.rpccert=/certs/rpc.cert"
fi

if [[ "$LND_BACKEND" == "bitcoind" ]]; then
  PARAMS+=" --bitcoind.zmqpubrawblock=$ZMQ_PUBRAWBLOCK"
  PARAMS+=" --bitcoind.zmqpubrawtx=$ZMQ_PUBRAWTX"
fi

if [[ -n "$LND_P2P_BIND" ]]; then
  PARAMS+=" --listen=$LND_P2P_BIND:$LND_P2P_PORT"
fi

if [[ -n "$LND_RPC_BIND" ]]; then
  PARAMS+=" --rpclisten=$LND_RPC_BIND:$LND_RPC_PORT"
fi

if [[ -n "$LND_REST_BIND" ]]; then
  PARAMS+=" --restlisten=$LND_REST_BIND:$LND_REST_PORT"
fi

if [[ -n "$DEBUG" ]]; then
  PARAMS+=" --debuglevel=$DEBUG"
fi

PARAMS+=" --noseedbackup"

set -x
exec lnd ${PARAMS} ${LND_EXTRA_PARAMS} "$@"
