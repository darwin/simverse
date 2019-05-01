#!/usr/bin/env bash

# wait for shared certificate creation
while [[ ! -f /certs/rpc.cert ]]; do sleep 1; done

./setup.sh &

./start-btcwallet.sh &

exec start-btcd.sh
