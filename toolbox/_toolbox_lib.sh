# shellcheck shell=bash

# this is a shell library, it should be sourced by scripts in toolbox

set -e -o pipefail

export REAL_TOOLBOX_DIR
REAL_TOOLBOX_DIR="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"

pushd "$REAL_TOOLBOX_DIR" > /dev/null
source _toolbox_config.sh
popd > /dev/null

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

BC_ARGS=(-l "$REAL_TOOLBOX_DIR/_toolbox.bc")

trim() {
  local str
  str=$(cat)
  if [[ "$str" =~ [^[:space:]](.*[^[:space:]])? ]]; then
    printf "%s" "${BASH_REMATCH[0]}"
  else
    echo -n "$str"
  fi
}

sat2btc() {
  local number=${1}
  if [[ -z "$number" ]]; then
    read -r number
  fi
  echo "${number} / 100000000" | bc "${BC_ARGS[@]}" | xargs printf "%.*f\n" 8
}

btc2sat() {
  local number=${1}
  if [[ -z "$number" ]]; then
    read -r number
  fi
  echo "${number} * 100000000" | bc "${BC_ARGS[@]}" | xargs printf "%.*f\n" 0
}

btc2msat() {
  local number=${1}
  if [[ -z "$number" ]]; then
    read -r number
  fi
  echo "${number} * 100000000000" | bc "${BC_ARGS[@]}" | xargs printf "%.*f\n" 0
}

msat2btc() {
  local number=${1}
  if [[ -z "$number" ]]; then
    read -r number
  fi
  echo "${number} / 100000000000" | bc "${BC_ARGS[@]}" | xargs printf "%.*f\n" 8
}

unquote() {
  tr -d '"'
}

is() {
  test "$(echo "$1" | bc "${BC_ARGS[@]}")" -eq 1
}

compute() {
  echo "$1" | bc "${BC_ARGS[@]}"
}

uppercase() {
  tr '[:lower:]' '[:upper:]'
}

ln_connect_string() {
  local person=${1:-alice}
  local pubkey
  if ! pubkey=$(pubkey "$person"); then
    return 1
  fi
  echo "$pubkey@$person"
}

# checks whether btcd is our master bitcoin node
# we branch some code based on this info
is_btcd_master() {
  local container
  container=$(lookup_container 1 role bitcoin)
  if [[ -z "$container" ]]; then
    echo_err "unable to lookup first container with role bitcoin"
    exit 1
  fi

  local flavor
  flavor=$(inspect_container "${container}" flavor)
  if [[ -z "$flavor" ]]; then
    echo_err "unable to determine flavor of service in container '$container'"
    exit 1
  fi

  test "$flavor" == "btcd"
}

get_flavor() {
  local person=${1:?required}
  local container
  container=$(docker-compose ps -q "$person")
  if [[ -z "$container" ]]; then
    echo_err "unable to lookup container for for '$person'"
    exit 1
  fi

  local flavor
  flavor=$(inspect_container "${container}" flavor)
  if [[ -z "$flavor" ]]; then
    echo_err "unable to determine flavor of service for '$person'"
    exit 1
  fi

  echo -n "$flavor"
}

get_role() {
  local person=${1:?required}
  local container
  container=$(docker-compose ps -q "$person")
  if [[ -z "$container" ]]; then
    echo_err "unable to lookup container for for '$person'"
    exit 1
  fi

  local role
  role=$(inspect_container "${container}" role)
  if [[ -z "$role" ]]; then
    echo_err "unable to determine role of service for '$person'"
    exit 1
  fi

  echo -n "$role"
}

wait_for() {
  local msg=${1:?required}
  local cmd=${2:?required}
  local cmd2=${3}
  local max=${4:-100}
  local cmd2_interval=${5:-5}
  local interval=${6:-1}

  local counter=1
  local status
  local saved_opts
  while true; do
    saved_opts="set -$-"
    set +e
    eval "${cmd}" > /dev/null 2>&1;
    status=$?
    eval "${saved_opts}"
    if [[ "$status" -eq 0 ]]; then
      if [[ "$counter" -ne 1 ]]; then
        echo
      fi
      return 0
    fi
    if [[ "$counter" -eq 1 ]]; then
      echo -n "Waiting for $msg. Zzz.."
    fi
    sleep "${interval}"
    echo -n "."
    if  [[ -n "$cmd2" ]]; then
      if ! (( "$counter" % "$cmd2_interval" )); then
        echo
        saved_opts="set -$-"
        set +e
        eval "${cmd2}"
        eval "${saved_opts}"
        echo -n "Waiting for $msg. Zzz.."
      fi
    fi
    ((++counter))
    if [[ ${counter} -gt ${max} ]]; then
      echo
      echo_err "FATAL: wait_for stuck waiting for '$msg' (tried $max times with interval of $interval sec)"
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

wait_is() {
  local condition=${1:?required}
  wait_for "condition '${condition}' to be met" "is \"$condition\""
}