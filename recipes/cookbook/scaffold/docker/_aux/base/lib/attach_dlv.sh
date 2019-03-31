#!/usr/bin/env bash

set -e -o pipefail

PROCESS=${1}
PORT=${2}

PID=$(pidof ${PROCESS})

if [[ -z "$PID" ]]; then
  echo "unable to retrieve a PID for '$PROCESS'"
  ps
  exit 1
fi

set -x
dlv --listen=0.0.0.0:${PORT} --log --headless=true --api-version=2 attach ${PID}