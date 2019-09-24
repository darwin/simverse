#!/usr/bin/env bash

set -e -o pipefail

SIMVERSE_VERBOSE_ALIASES=${SIMVERSE_VERBOSE_ALIASES}
SIMVERSE_DONT_BEAUTIFY_ALIASES=${SIMVERSE_DONT_BEAUTIFY_ALIASES}

beautify_if_needed() {
  local first_line
  set +e
  read -r first_line
  set -e
  if [[ -n "$SIMVERSE_DONT_BEAUTIFY_ALIASES" || "$first_line" != "{"* ]]; then
    echo "$first_line"; cat -
  else
    ( echo "$first_line"; cat - ) | jq
  fi
}

echo_command_if_needed() {
  if [[ -n "$SIMVERSE_VERBOSE_ALIASES" && -t 1 ]]; then
    echo ">" "$(basename "$0")" "$@"
  fi
}

prepare_docker_compose_exec_args() {
  if [[ ! -t 1 ]]; then
    echo "-T"
  fi
}