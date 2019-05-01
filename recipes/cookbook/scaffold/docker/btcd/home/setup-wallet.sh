#!/usr/bin/env bash

source lib/init.sh

FAUCET_ADDR_PRIVATE_KEY=${FAUCET_ADDR_PRIVATE_KEY:?required}

echo "Initializing wallet..."

# we need to wait for btcwallet to connect to btcd to avoid "-1: Chain RPC is inactive" errors
PROBE_CMD="./btcctl.sh --wallet getbalance"
PROBE_COUNTER=1
MAX_PROBES=100
while ! ${PROBE_CMD} > /dev/null 2>&1; do
  sleep 1
  ((++PROBE_COUNTER))
  if [[ ${PROBE_COUNTER} -gt ${MAX_PROBES} ]]; then
    echo "btcwallet didn't come online in time"
    exit 1 # this will stop whole container with failure and bring it to user attention
  fi
done

set -x
./btcctl.sh --wallet walletpassphrase "password" 0
./btcctl.sh --wallet importprivkey ${FAUCET_ADDR_PRIVATE_KEY} imported