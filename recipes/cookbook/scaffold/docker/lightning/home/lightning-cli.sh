#!/usr/bin/env bash

source lib/init.sh
source lib/utils.sh

LIGHTNING_CLI_EXTRA_PARAMS=${LIGHTNING_CLI_EXTRA_PARAMS}

PARAMS=""
PARAMS+=" --network regtest"
PARAMS+=" --rpc-file=${LIGHTNINGD_RPC_DIR_SIMVERSE}/lightning-rpc"

#set -x
exec lightning-cli ${PARAMS} ${LIGHTNING_CLI_EXTRA_PARAMS} "$@"
