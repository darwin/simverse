#!/usr/bin/env bash

source lib/init.sh
source lib/utils.sh

CERTS_DIR=/certs
if [[ -f "$CERTS_DIR/rpc.cert" ]]; then
  echo "certificate present at '$CERTS_DIR/rpc.cert', nothing to do"
else
  echo "certificate not present at '$CERTS_DIR/rpc.cert', generating a new one..."
  pushd "$CERTS_DIR" > /dev/null
  generate_cert "rpc"
  openssl x509 -text -noout -in "rpc.cert"
  popd
fi

# we use this in ./sv to check if simnet is running
PRE_SIGNAL_PORT=${PRE_SIGNAL_PORT:?not specified}
set -x
exec nc -lk ${PRE_SIGNAL_PORT}
