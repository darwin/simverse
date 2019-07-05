#!/usr/bin/env bash

source lib/init.sh
source lib/report.sh
source lib/utils.sh

SIMNET_NAME=${SIMNET_NAME:?required}

CERTS_DIR=~/certs
if [[ -f "$CERTS_DIR/rpc.cert" ]]; then
  echo "certificate present at '$CERTS_DIR/rpc.cert', nothing to do"
else
  echo "certificate not present at '$CERTS_DIR/rpc.cert', generating a new one..."
  pushd "$CERTS_DIR" > /dev/null
  generate_cert "rpc"
  # openssl x509 -text -noout -in "rpc.cert"
  popd
fi

# we use this in ./sv to check if simnet is running
signal_service_ready "$SIMNET_NAME"
