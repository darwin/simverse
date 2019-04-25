#!/usr/bin/env bash

source lib/init.sh
source lib/utils.sh

PARAMS=""

PARAMS+=" --network=regtest"

#set -x
exec lncli ${PARAMS} "$@"
