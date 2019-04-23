#!/usr/bin/env bash

source lib/init.sh

FAUCET_ADDR_PRIVATE_KEY=${FAUCET_ADDR_PRIVATE_KEY:?required}

echo "Initializing wallet..."

set -x

./bitcoin-cli.sh importprivkey ${FAUCET_ADDR_PRIVATE_KEY} imported