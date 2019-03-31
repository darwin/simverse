#!/usr/bin/env bash

source lib/init.sh

# we have to wait for btcwallet to come online, it can be slow under a VM
./lib/wait-for -t 120 localhost:18554 -- ./setup-ready.sh
