#!/usr/bin/env bash

source lib/init.sh

./setup.sh &

# start container service in background
./container-server.sh &

exec ./bitcoind.sh
