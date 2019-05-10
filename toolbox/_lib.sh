#!/usr/bin/env bash

set -e -o pipefail

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
CHANNEL_CONF_COUNT=10
COINBASE_MATURITY=100

ROOT_DIR="../.."
DOCKER_DIR="$ROOT_DIR/docker"
DOCKER_LNCLI="$DOCKER_DIR/lncli"
BTCCTL="$DOCKER_DIR/btcctl.sh"

BIN_DIR="$(realpath $(dirname "${BASH_SOURCE[0]}"))"

BC_ARGS="-l $BIN_DIR/_lib.bc"

trim() {
  local str
  str=$(cat)
  if [[ "$str" =~ [^[:space:]](.*[^[:space:]])? ]]; then
    printf "%s" "$BASH_REMATCH"
  else
    echo -n "$str"
  fi
}

sat2btc() {
  local number=${1}
  if [[ -z "$number" ]]; then
    read number
  fi
  echo "${number} / 100000000" | bc ${BC_ARGS} | xargs printf "%.*f\n" 8
}

btc2sat() {
  local number=${1}
  if [[ -z "$number" ]]; then
    read number
  fi
  echo "${number} * 100000000" | bc ${BC_ARGS} | xargs printf "%.*f\n" 0
}

btc2msat() {
  local number=${1}
  if [[ -z "$number" ]]; then
    read number
  fi
  echo "${number} * 100000000000" | bc ${BC_ARGS} | xargs printf "%.*f\n" 0
}

msat2btc() {
  local number=${1}
  if [[ -z "$number" ]]; then
    read number
  fi
  echo "${number} / 100000000000" | bc ${BC_ARGS} | xargs printf "%.*f\n" 8
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
  if [[ -z "$container" ]]; then
    echo_err "unable to lookup container for for '$person'"
    exit 1
  fi

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
  if [[ -z "$container" ]]; then
    echo_err "unable to lookup container for for '$person'"
    exit 1
  fi

  local role=$(inspect_container ${container} role)
  if [[ -z "role" ]]; then
    echo_err "unable to determine role of service for '$person'"
    exit 1
  fi

  echo -n "$role"
}

wait_for() {
  local msg=${1:?required}
  local cmd=${2:?required}
  local cmd2=${3}
  local interval=${4:-5}
  local max=${5:-100}

  local counter=1
  local status
  while true; do
    set +e
    eval "${cmd}" > /dev/null 2>&1;
    status=$?
    set -e
    if [[ "$status" -eq 0 ]]; then
      if [[ "$counter" -ne 1 ]]; then
        echo
      fi
      return 0
    fi
    if [[ "$counter" -eq 1 ]]; then
      echo -n "Waiting for $msg. Zzz.."
    fi
    sleep 1
    echo -n "."
    if  [[ -n "$cmd2" ]]; then
      if ! (( "$counter" % "$interval" )); then
        echo
        set +e
        eval "${cmd2}"
        set -e
        echo -n "Waiting for $msg. Zzz.."
      fi
    fi
    ((++counter))
    if [[ ${counter} -gt ${max} ]]; then
      echo
      echo_err "FATAL: wait_for stuck waiting for '$msg' (tried $max times)"
      exit 1
    fi
  done
}

wait_for_onchain_balance() {
  local person=${1:?required}
  local expected_amount=${2:?required}

  local cmd="is \"\$(onchain_balance \"$person\") >= $expected_amount\""
  wait_for "$person to receive onchain balance of $expected_amount BTC" "$cmd"
}

wait_for_route() {
  local from_person=${1:?required}
  local to_person=${2:?required}
  local amt_btc=${3}

  local cmd="get_route \"$from_person\" \"$to_person\" ${amt_btc}"
  local cmd2="generate 1"
  wait_for "route between $from_person and $to_person" "$cmd" "$cmd2"
}

wait_sync_one() {
  local person=${1:?required}

  local cmd="\"$person\" getinfo"
  wait_for "$person to become available" "$cmd"

  local flavor
  flavor=$(get_flavor "$person")
  local cmd
  case "$flavor" in
    lnd)
      cmd="[[ \$(\"$person\" getinfo | jq \".synced_to_chain\") == \"true\" ]]"
      wait_for "$person to sync" "$cmd"
      ;;
    lightning)
      cmd="[[ \$(chain_height) == \$(\"$person\" getinfo | jq .blockheight) ]]"
      wait_for "$person to sync" "$cmd"
      ;;
    *)
      echo_err "unsupported flavor type '$flavor' for '$person'"
      return 1
      ;;
  esac
}

wait_sync() {
  for person in "$@"; do
    wait_sync_one "$person"
  done
}

wait_simnet_ready() {
  wait_for "simnet to get ready" "simnet_ready"
}