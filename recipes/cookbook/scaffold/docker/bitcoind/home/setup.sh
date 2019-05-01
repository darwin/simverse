#!/usr/bin/env bash

source lib/init.sh

# TODO: replace this with polling
sleep 10

./setup-wallet.sh

./setup-chain.sh
