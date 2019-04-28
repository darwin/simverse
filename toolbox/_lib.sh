#!/usr/bin/env bash

set -e -E -o pipefail

echo_err() {
  printf "\e[31m%s\e[0m\n" "$*" >&2;
}

# https://gist.github.com/ahendrix/7030300
report_error() {
  local err=$?
  set +o xtrace
  local code="${1:-1}"
  echo_err "Error in ${BASH_SOURCE[1]}:${BASH_LINENO[0]}. '${BASH_COMMAND}' exited with status $err"
  # Print out the stack trace described by $function_stack
  if [[ ${#FUNCNAME[@]} -gt 2 ]]
  then
    echo_err "Call tree:"
    for ((i=1;i<${#FUNCNAME[@]}-1;i++))
    do
      echo_err " $i: ${BASH_SOURCE[$i+1]}:${BASH_LINENO[$i]} ${FUNCNAME[$i]}(...)"
    done
  fi
  echo_err "Exiting with status ${code}"
  exit "${code}"
}

trap report_error ERR


realpath() {
  [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
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

btc2msat() {
  local number
  read number
  echo "${number} * 100000000000" | bc ${BC_ARGS} | xargs printf "%.*f\n" 0
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

ln_connect_string() {
  local person=${1:-alice}
  local pubkey
  pubkey=$(pubkey "$person")
  if [[ $? -ne 0 ]]; then
    return 1
  fi
  echo "$pubkey@$person"
}

# checks whether btcd is our master bitcoin node
# we branch some code based on this info
is_btcd_master() {
  local container=$(lookup_container 1 role bitcoin)
  if [[ -z "$container" ]]; then
    echo_err "unable to lookup first container with role bitcoin"
    exit 1
  fi

  local flavor=$(inspect_container ${container} flavor)
  if [[ -z "flavor" ]]; then
    echo_err "unable to determine flavor of service in container '$container'"
    exit 1
  fi

  test "$flavor" == "btcd"
}

get_flavor() {
  local person=${1:?required}
  local container=$(docker-compose ps -q "$person")
  local flavor=$(inspect_container ${container} flavor)
  if [[ -z "flavor" ]]; then
    echo_err "unable to determine flavor of service for '$person'"
    exit 1
  fi

  echo -n "$flavor"
}

get_role() {
  local person=${1:?required}
  local container=$(docker-compose ps -q "$person")
  local role=$(inspect_container ${container} role)
  if [[ -z "flavor" ]]; then
    echo_err "unable to determine role of service for '$person'"
    exit 1
  fi

  echo -n "$role"
}

wait_for_onchain_balance() {
  local person=${1:?required}
  local expected_amount=${2:?required}
  local counter=1
  local max=100
  while is "$(onchain_balance "$person") < $expected_amount"  > /dev/null 2>&1; do
    sleep 1
    echo -n "."
    ((++counter))
    if [[ ${counter} -gt ${max} ]]; then
      echo
      echo "wait_for_onchain_balance stuck waiting for '$person' to receive $expected_amount BTC on-chain"
      exit 1
    fi
  done
  echo
}