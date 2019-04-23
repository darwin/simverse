#!/usr/bin/env bash

# give bitcoin nodes some head start
sleep 5

# wait for shared certificate creation
while [[ ! -f /certs/rpc.cert ]]; do sleep 1; done

exec lnd.sh