#!/usr/bin/env bash

RECIPE=${1:?required}

SIMVERSE_HOME=${SIMVERSE_HOME:?required}
SIMVERSE_WORKSPACE=${SIMVERSE_WORKSPACE:?required}

cd "$(dirname "${BASH_SOURCE[0]}")"

source ../../../toolbox/_lib.sh
source ../../_lib/helpers.sh
source ../../_lib/travis.sh

SIMNET_NAME="t1_$RECIPE"

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
  announce "tearing down $SIMNET_NAME"
  ./dc down
}

trap tear_down EXIT

if ! wait_for_bitcoin_ready; then
  exit 2
fi

# give LND a bit more time
# TODO: revisit this
sleep 5

# ---------------------------------------------------------------------------------------------------------------------------

announce "running $SIMNET_NAME tests..."

check "connect alice bob"
check "fund alice 10"
check "oc alice bob 0.1"
check "is \"\$(ln_balance bob) == 0\""
sleep 20 # ad-hoc pause, c-lighting is slow to recognize new channel TODO: implement polling of channel discovery
check "pay alice bob 0.01"
check "is \"\$(ln_balance bob) == 0.01\""

# ---------------------------------------------------------------------------------------------------------------------------

announce "test-case $SIMNET_NAME successfully completed"