#!/usr/bin/env bash

RECIPE=${RECIPE:?require}
TRAVIS=${TRAVIS}

SIMNET_NAME=${SIMNET_NAME:?required}
SIMVERSE_HOME=${SIMVERSE_HOME:?required}
SIMVERSE_WORKSPACE=${SIMVERSE_WORKSPACE:?required}
SIMVERSE_NOANSI=${SIMVERSE_NOANSI}
SIMVERSE_DEBUG_TEST=${SIMVERSE_DEBUG_TEST}
SIMVERSE_SHELL=${SIMVERSE_SHELL:-$SHELL}

if [[ -n "$TRAVIS" ]]; then
  SIMVERSE_NOANSI=1
fi

DOCKER_COMPOSE_OPTS=
if [[ -n "$SIMVERSE_NOANSI" ]]; then
  DOCKER_COMPOSE_OPTS="--no-ansi"
fi

cd "$(dirname "${BASH_SOURCE[0]}")"

source ../../toolbox/_toolbox_lib.sh
source helpers.sh

# ---------------------------------------------------------------------------------------------------------------------------

cd "${SIMVERSE_HOME}"

log_section start "prepare_simnet"
  announce "creating simnet '$SIMNET_NAME'..."
  ./sv create ${RECIPE} ${SIMNET_NAME} --yes
  enter_simnet ${SIMNET_NAME}
log_section end "prepare_simnet"

log_section start "build_docker_containers"
  announce "building docker containers..."
  ./dc ${DOCKER_COMPOSE_OPTS} build
log_section end "build_docker_containers"

log_section start "start_docker_containers"
  announce "starting docker containers..."
  ./dc ${DOCKER_COMPOSE_OPTS} up -d
log_section end "start_docker_containers"

tear_down() {
  if [[ $? -ne 0 ]]; then
    brief
    if [[ -n "$SIMVERSE_DEBUG_TEST" ]]; then
      echo "entering shell for debugging because SIMVERSE_DEBUG_TEST is set:"
      "$SIMVERSE_SHELL"
    fi
  fi

  log_section start "stop_docker_containers"
    announce "stopping docker containers..."
    ./dc ${DOCKER_COMPOSE_OPTS} down
  log_section end "stop_docker_containers"
}

trap tear_down EXIT

if ! wait_simnet_ready; then
  exit 2
fi
