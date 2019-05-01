#!/usr/bin/env bash

source lib/init.sh
source lib/utils.sh

./setup-wallet.sh

./setup-chain.sh

signal_service_ready