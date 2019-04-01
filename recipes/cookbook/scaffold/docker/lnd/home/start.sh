#!/usr/bin/env bash

# wait for shared certificate creation
while [[ ! -f /certs/rpc.cert ]]; do sleep 1; done

exec lnd.sh