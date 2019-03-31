#!/usr/bin/env bash

source lib/init.sh

# This trap dance is here to gracefully interrupt our background/child processes.
# We want to run btcd and btcwallet from the same script, so we have to launch them in background and wait for their exit.
# We also want to trap relevant signals and forward them to child processes.
# For example in case of SIGINT (see docker-compose's stop_signal) we trap it and send it to all alive child processes.
# Note that we cannot use simple exec[1] here because we have multiple commands to run.
#
# [1] https://github.com/lightningnetwork/lnd/commit/132c67d414067a29509aefe7066cd7e84656b644#diff-05b6053c41a2130afd6fc3b158bda4e6

terminate_gracefully() {
  local pid=$1
  local signal=$2
  if [[ -n "$pid" ]]; then
    set +e
    kill -s ${signal} "$pid" > /dev/null 2>&1; # ignore kill output because process might not exist anymore
    set -e
    wait "$pid"
  fi
}

interrupt_handler() {
  local signal=$1
  terminate_gracefully ${SETUP_PID} ${signal}
  terminate_gracefully ${BTCWALLET_PID} ${signal}
  terminate_gracefully ${BTCD_PID} ${signal}
}

# https://stackoverflow.com/a/2183063/84283
trap_with_arg() {
  local func=$1
  local _unused=$@ # to silence IntelliJ bash support warnings
  shift
  for sig ; do
    trap "${func} ${sig}" "$sig"
  done
}

trap_with_arg interrupt_handler INT TERM EXIT

./start-btcd.sh &
BTCD_PID=$!

./start-btcwallet.sh &
BTCWALLET_PID=$!

# optionally we want to do some initial setup
./setup.sh &
SETUP_PID=$!

wait ${SETUP_PID}

wait ${BTCWALLET_PID}

wait ${BTCD_PID}
