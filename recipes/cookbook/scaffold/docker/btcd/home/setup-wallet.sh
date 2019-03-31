#!/usr/bin/env bash

source lib/init.sh

echo "Initializing wallet.."

set -x

./btcctl.sh --wallet walletpassphrase "password" 0
./btcctl.sh --wallet importprivkey FwKY4zwscP47RKYWjiDJZxUTbWcyXRXvrAhQ2iLEuJXcRiLa7tYy imported