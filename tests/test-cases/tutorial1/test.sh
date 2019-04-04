#!/usr/bin/env bash

set -e -o pipefail

SIMVERSE_HOME=${SIMVERSE_HOME:?required}
SIMVERSE_WORKSPACE=${SIMVERSE_WORKSPACE:?required}

cd "$(dirname "${BASH_SOURCE[0]}")"

source ../../_lib/helpers.sh
source ../../_lib/travis.sh

SIMNET_NAME=$(basename $(pwd))

# ---------------------------------------------------------------------------------------------------------------------------

cd "${SIMVERSE_HOME}"

travis_fold start "prepare-$SIMNET_NAME"
announce "preparing $SIMNET_NAME simnet..."

./sv create ${SIMNET_NAME} b1l2 --yes

enter_simnet ${SIMNET_NAME}

./dc build

travis_fold end "prepare-$SIMNET_NAME"

./dc up -d

trap "./dc down" EXIT

if ! wait_for_btcd_ready; then
  exit 2
fi

# ---------------------------------------------------------------------------------------------------------------------------

announce "running $SIMNET_NAME tests..."

present connect alice bob
present fund alice 10
present oc alice bob 0.1
present test $(get_channel_balance bob) -eq 0
present pay alice bob 0.01
present test $(get_channel_balance bob) -eq 1000000

# ---------------------------------------------------------------------------------------------------------------------------

announce "test-case $SIMNET_NAME successfully completed"