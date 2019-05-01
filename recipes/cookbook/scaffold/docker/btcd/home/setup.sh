#!/usr/bin/env bash

source lib/init.sh
source lib/utils.sh

./setup-wallet.sh

./setup-segwit.sh

signal_service_ready