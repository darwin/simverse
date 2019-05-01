#!/usr/bin/env bash

source lib/init.sh

BITCOIN_COUNTER=${BITCOIN_COUNTER:?required}

# always mine at least one block, this block might get orphaned by master node
./btcctl.sh generate 1

# mine for segwit activation only on first bitcoin node
if [[ ! "$BITCOIN_COUNTER" -eq 1 ]]; then
  exit 0
fi

# Prevent: "has witness data, but segwit isn't active yet"
#  "This means that the block height of the simnet blockchain is not high enough.
#   The threshold for segwit activation is 300 blocks on simnet."
# source: https://degreesofzero.com/article/shared-private-lightning-network.html
NUM_BLOCKS_REQUIRED=432 # https://gist.github.com/t4sk/0bc6b35a26998b9007d68f376a852636
BLOCKS=$(./btcctl.sh getblockcount)
if [[ "$BLOCKS" -lt "$NUM_BLOCKS_REQUIRED" ]]; then
  echo "Activating segwit..."
  ./btcctl.sh generate ${NUM_BLOCKS_REQUIRED} > /dev/null
fi