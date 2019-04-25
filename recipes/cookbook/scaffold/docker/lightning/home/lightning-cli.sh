#!/usr/bin/env bash

source lib/init.sh
source lib/utils.sh

LIGHTNING_CLI_EXTRA_PARAMS=${LIGHTNING_CLI_EXTRA_PARAMS}

PARAMS=""

#set -x
exec lightning-cli ${PARAMS} ${LIGHTNING_CLI_EXTRA_PARAMS} "$@"
