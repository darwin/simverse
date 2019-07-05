#!/usr/bin/env bash

source lib/init.sh
source lib/report.sh

./setup.sh &

./container-server.sh &

exec ./bitcoind.sh
