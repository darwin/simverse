#!/usr/bin/env bash

RECIPE=${1:?required}
SIMNET_NAME="t02_$RECIPE"

cd "$(dirname "${BASH_SOURCE[0]}")"

source ../../_lib/prepare-test.sh

# ---------------------------------------------------------------------------------------------------------------------------

announce "running $SIMNET_NAME tests..."

# LN state: alice <-0.1--0.0-> charlie <-0.1--0.0-> bob
#
# Payment alice -> bob of 0.01
#
# resulting LN state: alice <-0.09--0.01-> charlie <-0.09--0.01-> bob

# init connections
check "./init"

# funding
check "fund alice 10"
check "fund charlie 5"

# open channels
check "open_channel alice charlie 0.1"
check "open_channel charlie bob 0.1"

# perform payment
check "is \"\$(ln_balance bob) == 0\""
check "wait_for_route alice bob"
check "pay alice bob 0.01"
check "is \"\$(ln_balance bob) == 0.01\""
check "is \"\$(ln_balance charlie) > 0.099\"" # losing on fees?

# ---------------------------------------------------------------------------------------------------------------------------

announce "test-case $SIMNET_NAME successfully completed"