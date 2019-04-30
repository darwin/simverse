#!/usr/bin/env bash

SIMNET_NAME=${SIMNET_NAME:?required}
RECIPE=${RECIPE:?require}
SIMVERSE_HOME=${SIMVERSE_HOME:?required}
SIMVERSE_WORKSPACE=${SIMVERSE_WORKSPACE:?required}

cd "$(dirname "${BASH_SOURCE[0]}")"

source ../../toolbox/_lib.sh
source helpers.sh
source travis.sh

# ---------------------------------------------------------------------------------------------------------------------------

cd "${SIMVERSE_HOME}"

travis_section start "prepare_simnet"
  announce "creating simnet '$SIMNET_NAME'..."
  ./sv create ${RECIPE} ${SIMNET_NAME} --yes
  enter_simnet ${SIMNET_NAME}
travis_section end "prepare_simnet"

travis_section start "build_docker_containers"
  announce "building docker containers..."
  ./dc build
travis_section end "build_docker_containers"

travis_section start "start_docker_containers"
  announce "starting docker containers..."
  ./dc up -d
travis_section end "start_docker_containers"

tear_down() {
  if [[ $? -ne 0 ]]; then
    if [[ -n "$SIMVERSE_DEBUG_TEST" ]]; then
      echo "entering shell for debugging because SIMVERSE_DEBUG_TEST is set:"
      "$SIMVERSE_SHELL"
    fi
  fi

  travis_section start "stop_docker_containers"
    announce "stopping docker containers..."
    ./dc down
  travis_section end "stop_docker_containers"
}

trap tear_down EXIT

announce "waiting for docker containers to warm up..."
# this is here to wait for ln nodes to start inside the container
# TODO: replace with polling
sleep 15

if ! wait_for_bitcoin_ready; then
  exit 2
fi