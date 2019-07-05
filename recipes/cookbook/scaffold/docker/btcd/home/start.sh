#!/usr/bin/env bash

source lib/init.sh
source lib/report.sh

# wait for shared certificate creation
while [[ ! -f /certs/rpc.cert ]]; do sleep 1; done

./setup.sh &

./start-btcwallet.sh &

# start container service in background
./container-server.sh &

exec start-btcd.sh
