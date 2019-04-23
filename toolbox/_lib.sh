#!/usr/bin/env bash

set -e -o pipefail

realpath() {
  [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

echo_err() {
  printf "\e[31m%s\e[0m\n" "$*" >&2;
}

TX_CONF_COUNT=6
COINBASE_MATURITY=100

ROOT_DIR="../.."
DOCKER_DIR="$ROOT_DIR/docker"
DOCKER_LNCLI="$DOCKER_DIR/lncli"
BTCCTL="$DOCKER_DIR/btcctl.sh"

BIN_DIR="$(realpath $(dirname "${BASH_SOURCE[0]}"))"

BC_ARGS="-l $BIN_DIR/_lib.bc"

trim() {
  local str
  read str
  [[ "$str" =~ [^[:space:]](.*[^[:space:]])? ]]
  printf "%s" "$BASH_REMATCH"
}

sat2btc() {
  local number
  read number
  echo "${number} / 100000000" | bc ${BC_ARGS} | xargs printf "%.*f\n" 8
}

btc2sat() {
  local number
  read number
  echo "${number} * 100000000" | bc ${BC_ARGS} | xargs printf "%.*f\n" 0
}

unquote() {
  tr -d '"'
}

is() {
  test $(echo "$1" | bc ${BC_ARGS}) -eq 1
}

compute() {
  echo "$1" | bc ${BC_ARGS}
}

uppercase() {
  tr a-z A-Z
}

lnd_connect_string() {
  local person=${1:-alice}
  local pubkey
  pubkey=$(pubkey ${person})
  local status=$?
  if [[ ${status} -ne 0 ]]; then
    return 1
  fi
  echo "$pubkey@$person"
}

# checks whether btcd is our master bitcoin node
# we branch some code based on this info
is_btcd_master() {
  local host=$(lookup_host 1 role bitcoin)
  if [[ -z "$host" ]]; then
    echo_err "unable to lookup first host with role bitcoin"
    exit 1
  fi

  local flavor=$(inspect_host ${host} flavor)
  if [[ -z "flavor" ]]; then
    echo_err "unable to determine flavor of service with host '$host'"
    exit 1
  fi

  test "$flavor" == "btcd"
}