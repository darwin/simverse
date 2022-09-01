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

# must be "" (empty name), this name is hard-coded in eclair:
# https://github.com/ACINQ/eclair/blob/662e0c4bcc1dec24f9aad2bd526866a8a056153f/eclair-core/src/main/scala/fr/acinq/eclair/blockchain/bitcoind/rpc/BasicBitcoinJsonRPCClient.scala#L40
# https://gitter.im/ACINQ/eclair?at=5e48f793c8da1343d4540a44
# with a different name we would get "bitcoind must have wallet support enabled" from:
# https://github.com/ACINQ/eclair/blob/daddfc007fe569c89bb854ef5d672614d397e91e/eclair-core/src/main/scala/fr/acinq/eclair/Setup.scala#L150
# that error message is quite misleading in this particular situation, it should not swallow original error
# and should communicate both, something like "unable to get balance, error: Requested wallet does not exist or is not loaded (code: -18)"
WALLET_NAME=""
WALLET_DIR="$HOME/.bitcoin/regtest/wallets/$WALLET_NAME"
if [[ -d "$WALLET_DIR" ]]; then
  rm -rf "$WALLET_DIR"
fi

# If a wallet is loaded we should unload it
if ./bitcoin-cli.sh getwalletinfo; then                                               
  ./bitcoin-cli.sh unloadwallet ""                                                    
fi 

./bitcoin-cli.sh -named createwallet wallet_name="$WALLET_DIR" descriptors=false
./bitcoin-cli.sh -rpcwallet="$WALLET_DIR" importprivkey "${FAUCET_ADDR_PRIVATE_KEY}" imported
