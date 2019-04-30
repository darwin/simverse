#!/usr/bin/env bash

echo_err() {
  printf "\e[31m%s\e[0m\n" "$*" >&2;
}

wait_for_socket() {
  local port=${1:?required}
  local host=${2:-localhost}
  local max=${3:-100}
  local delay=${4:-1}

  local counter=1
  while ! nc -z "$host" "$port" > /dev/null 2>&1; do
    sleep ${delay}
    ((++counter))
    if [[ ${counter} -gt ${max} ]]; then
      echo_err "socket '$host:$port' didn't come online in time"
      return 1
    fi
  done
}