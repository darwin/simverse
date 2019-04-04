#!/usr/bin/env bash

echo_err() {
  printf "\e[31m%s\e[0m\n" "$*" >&2;
}

unquote() {
  tr -d '"'
}

# https://stackoverflow.com/a/17841619/84283
join_by() {
 local IFS="$1"
 shift
 echo "$*"
}

present() {
  local line="$(join_by " " ${@/eval/})"
  printf "\$ \e[33m%s\e[0m\n" "$line"
  "$@"
}

announce() {
  printf "\e[35m%s\e[0m\n" "$1"
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

wait_for_btcd_ready() {
  announce "waiting for btcd to mine 300 blocks..."
  set +e
  local probe_counter=1
  local delay=1
  local max_probes=(3*60) # approx 3min
  while ! [[ $(btcctl getinfo | jq '.blocks') -ge 300 ]] > /dev/null 2>&1; do
    # echo "$PROBE_COUNTER $(btcctl getinfo | jq '.blocks')"
    sleep ${delay}
    echo -n "."
    ((++probe_counter))
    if [[ ${probe_counter} -gt ${max_probes} ]]; then
      echo ""
      echo_err "btcd didn't reach expected 300 blocks in time"
      return 1
    fi
  done
  set -e
  echo ""
}

get_channel_balance() {
  local person=$1
  local balance=$(${person} channelbalance | jq ".balance" | unquote)
  if [[ -z "$balance" ]]; then
    echo "-1"
  fi
  echo ${balance}
}

