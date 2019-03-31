#!/usr/bin/env bash

source lib/init.sh

# give it a few more seconds, to avoid "-1: Chain RPC is inactive" errors
sleep 5

./setup-wallet.sh

./setup-segwit.sh

