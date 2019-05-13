#!/usr/bin/env bash

echo_err() {
  printf "\e[31m%s\e[0m\n" "$*" >&2;
}

unquote() {
  tr -d '"'
}

CHECK_COUNTER=1

check() {
  local command=${1:?required}
  local silent=${2}
  local status

  if [[ -z "$silent" ]]; then
    travis_section start "test.$CHECK_COUNTER"
    printf "\$ \e[33m%s\e[0m\n" "$command"
  fi
  local saved_opts="set -$-"
  set +e
  # partially evaluate our command arguments
  eval set -- ${command}
  status1=$?
  evaluated_arguments="$@" # this is for potential error message below
  if [[ "$status1" -eq 0 ]]; then
    # evaluate actual command with pre-evaluated arguments
    "$@"
    status2=$?
  fi
  eval "${saved_opts}"
  if [[ -z "$silent" ]]; then
    travis_section end "test.$CHECK_COUNTER"
    ((++CHECK_COUNTER))
  fi

  # print evaluated args on failure
  if [[ "$status1" -ne 0 ]]; then
    if [[ -z "$silent" ]]; then
      printf "!! \e[31m%s\e[0m\n" "$evaluated_arguments"
    fi
    return ${status1}
  fi
  if [[ "$status2" -ne 0 ]]; then
    if [[ -z "$silent" ]]; then
      printf "! \e[31m%s\e[0m\n" "$evaluated_arguments"
    fi
    return ${status2}
  fi
}

announce1() {
  printf "\e[35m%s\e[0m" "$1"
}

announce() {
  announce1 "$@"
  echo
}

# this is a replacement for ./sv enter ${SIMNET_NAME}
enter_simnet() {
  local SIMNET_NAME=$1

  SIMVERSE_HOME=${SIMVERSE_HOME:?required}
  SIMVERSE_WORKSPACE=${SIMVERSE_WORKSPACE:?required}

  . "$SIMVERSE_HOME/_defaults.sh"

  cd "$SIMVERSE_WORKSPACE"
  cd "$SIMNET_NAME"
  SIMNET_DIR=$(pwd -P)
  export PATH=$PATH:"$SIMNET_DIR/toolbox":"$SIMNET_DIR/aliases"
}

wait_for_bitcoin_ready() {
  local num_blocks=432
  announce1 "waiting for master bitcoin node to mine $num_blocks blocks "
  local saved_opts="set -$-"
  set +e
  local probe_counter=1
  local delay=1
  local max_probes=$(expr 3*60) # approx 3min
  while ! [[ $(chain_height) -ge ${num_blocks} ]] > /dev/null 2>&1; do
    # echo "$PROBE_COUNTER $(btcctl getinfo | jq '.blocks')"
    sleep ${delay}
    echo -n "."
    ((++probe_counter))
    if [[ ${probe_counter} -gt ${max_probes} ]]; then
      echo
      echo_err "master bitcoin node didn't reach expected $num_blocks blocks in time"
      eval "${saved_opts}"
      return 1
    fi
  done
  eval "${saved_opts}"
  echo
}