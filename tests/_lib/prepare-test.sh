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

travis_fold start "prepare-$SIMNET_NAME"
announce "preparing $SIMNET_NAME simnet..."

./sv create ${RECIPE} ${SIMNET_NAME} --yes

enter_simnet ${SIMNET_NAME}

./dc build

travis_fold end "prepare-$SIMNET_NAME"

./dc up -d

tear_down() {
  if [[ $? -ne 0 ]]; then
    if [[ -n "$SIMVERSE_DEBUG_TEST" ]]; then
      echo "entering shell for debugging because SIMVERSE_DEBUG_TEST is set:"
      "$SIMVERSE_SHELL"
    fi
  fi
  announce "tearing down $SIMNET_NAME"
  ./dc down
}

trap tear_down EXIT

if ! wait_for_bitcoin_ready; then
  exit 2
fi