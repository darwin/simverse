#!/usr/bin/env bash

pushd() {
    command pushd "$@" > /dev/null
}

popd() {
    command popd "$@" > /dev/null
}

echo_err() {
  printf "\e[31m%s\e[0m\n" "$*" >&2;
}

docker_image_exists() {
  test "$(docker images -q "$1" 2> /dev/null)" != ""
}

docker_image_rev() {
  local image_name=${1:?required}
  local rev="$(docker inspect --format "{{index .Config.Labels \"simverse.rev\" }}" "${image_name}")"
  if [[ -z "$rev" ]]; then
    echo -n "0";
  else
    echo -n "$rev"
  fi
}