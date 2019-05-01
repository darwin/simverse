#!/usr/bin/env bash

source lib/init.sh

FAUCET_ADDR_PRIVATE_KEY=${FAUCET_ADDR_PRIVATE_KEY:?required}

echo "Initializing wallet..."

# we need to wait for bitcoin-cli start responding
PROBE_CMD="./bitcoin-cli.sh -getinfo"
PROBE_COUNTER=1
MAX_PROBES=100
while ! ${PROBE_CMD} > /dev/null 2>&1; do
  sleep 1
  ((++PROBE_COUNTER))
  if [[ ${PROBE_COUNTER} -gt ${MAX_PROBES} ]]; then
    echo "bitcoin-cli didn't come online in time"
    exit 1 # this will stop whole container with failure and bring it to user attention
  fi
done

set -x
./bitcoin-cli.sh importprivkey ${FAUCET_ADDR_PRIVATE_KEY} imported