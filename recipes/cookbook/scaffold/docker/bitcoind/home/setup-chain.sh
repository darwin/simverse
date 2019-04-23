#!/usr/bin/env bash

source lib/init.sh

BITCOIN_COUNTER=${BITCOIN_COUNTER:?required}

# mine for segwit activation only on first bitcoin node
if [[ ! "$BITCOIN_COUNTER" -eq 1 ]]; then
  exit 0
fi

FAUCET_ADDR=${FAUCET_ADDR:?required}

NUM_BLOCKS_REQUIRED=500
BLOCKS=$(./bitcoin-cli.sh getblockcount)
if [[ "$BLOCKS" -lt "$NUM_BLOCKS_REQUIRED" ]]; then
  echo "Activating segwit..."
  ./bitcoin-cli.sh generatetoaddress ${NUM_BLOCKS_REQUIRED} ${FAUCET_ADDR}
fi