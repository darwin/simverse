#!/usr/bin/env bash

source lib/init.sh

./setup.sh &

./container-server.sh &

exec ./bitcoind.sh
