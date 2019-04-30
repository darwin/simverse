#!/usr/bin/env bash

RECIPE=${1:?required}
SIMNET_NAME="t01_$RECIPE"

cd "$(dirname "${BASH_SOURCE[0]}")"

source ../../_lib/prepare-test.sh

# ---------------------------------------------------------------------------------------------------------------------------

announce "running $SIMNET_NAME tests..."

check "wait_sync alice bob"
check "connect alice bob"
check "fund alice 10"
check "open_channel alice bob 0.1"
check "wait_for_route alice bob"
check "is \"\$(ln_balance bob) == 0\""
check "pay alice bob 0.01"
check "is \"\$(ln_balance bob) == 0.01\""

# ---------------------------------------------------------------------------------------------------------------------------

announce "test case $SIMNET_NAME successfully completed"