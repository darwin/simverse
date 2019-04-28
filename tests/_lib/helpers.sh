#!/usr/bin/env bash

echo_err() {
  printf "\e[31m%s\e[0m\n" "$*" >&2;
}

unquote() {
  tr -d '"'
}

check() {
  local command=${1:?required}
  local status
  # print the command
  printf "\$ \e[33m%s\e[0m\n" "$command"
  # eval the command
  set +e
  eval ${command}
  status=$?
  set -e
  # print evaluated args on failure
  if [[ "$status" -ne 0 ]]; then
    evaluated_arguments=$(eval echo -e ${command})
    printf "! \e[31m%s\e[0m\n" "$evaluated_arguments"
    return ${status}
  fi
}

announce() {
  printf "\e[35m%s\e[0m\n" "$1"
}

maybe_debug() {
  if [[ -n "$SIMVERSE_DEBUG_TEST" ]]; then
    echo "entering ad-hoc shell because SIMVERSE_DEBUG_TEST is set..."
    $SHELL
  fi
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
  local num_blocks=500
  announce "waiting for master bitcoin node to mine $num_blocks blocks..."
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
      echo ""
      echo_err "master bitcoin node didn't reach expected $num_blocks blocks in time"
      return 1
    fi
  done
  set -e
  echo ""
}