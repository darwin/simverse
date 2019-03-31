#!/usr/bin/env bash

source lib/init.sh
source lib/utils.sh

NETWORK=${NETWORK}

PARAMS=""

if [[ -n "$NETWORK" ]]; then
  PARAMS+=" --network=$NETWORK"
fi

PARAMS+=" $@"

#set -x
exec lncli ${PARAMS}
