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

# https://stackoverflow.com/a/24067243/84283
version_gt() {
  test "$(printf '%s\n' "$@" | sort --version-sort -r | head -n 1)" == "$1"
}

check_prereq() {
  local tool=${1:?required}
  local min_version=$2
  local version_cmd=${3:-$tool --version}

  if ! command -v "$tool" > /dev/null; then
    echo "Required prerequisite '$tool' is missing on your system. We didn't detect it on your \$PATH. Please install it."
    echo "Simverse requires version '$min_version' or higher."
    echo "For additional info see https://github.com/darwin/simverse#prerequisites."
    return 1
  fi

  if [[ -n "$min_version" ]]; then
    local actual_version
    actual_version=$(bash -c "$version_cmd")
    if ! version_gt "$actual_version" "$min_version"; then
      echo "Required prerequisite '$tool' is outdated on your system (we detected version '$actual_version'). Please update it."
      echo "Simverse requires version '$min_version' or higher."
      echo "For additional info see https://github.com/darwin/simverse#prerequisites."
      return 2
    fi
  fi
}

check_prereqs() {
  check_prereq bash 4.0 "echo '$BASH_VERSION'"
  check_prereq jq jq-1.6
  check_prereq git 2.0 "git --version | head -n 1 | cut -d ' ' -f 3"
  check_prereq docker 18.06 "docker --version | head -n 1 | tr , ' ' | cut -d ' ' -f 3"
  check_prereq docker-compose 1.24 "docker-compose --version | head -n 1 | tr , ' ' | cut -d ' ' -f 3"
}