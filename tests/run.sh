#!/usr/bin/env bash

set -e -o pipefail

LAUNCH_DIR=$(pwd -P)

SIMVERSE_DEBUG_TEST=${SIMVERSE_DEBUG_TEST}
SIMVERSE_TEST_REPOS=${SIMVERSE_TEST_REPOS}

cd "$(dirname "${BASH_SOURCE[0]}")"

TESTS_DIR="$(pwd -P)"

source _lib/helpers.sh

function print_error {
    read line file <<<$(caller)
    echo_err "Test runner failed on line $line of '$file':"
    cd ${LAUNCH_DIR}
    local content=$(sed "${line}q;d" "$file")
    echo_err "> $content"
}
trap print_error ERR

cd ..

export SIMVERSE_HOME="$(pwd -P)"

if [[ -n "$SIMVERSE_DEBUG_TEST" ]]; then
  TMP_DIR=/tmp/simverse-tests
  rm -rf "$TMP_DIR"
  mkdir -p "$TMP_DIR"
else
  TMP_DIR=$(mktemp -d -t simverse_tests.XXXXXXXX)
fi

if [[ ! "$TMP_DIR" || ! -d "$TMP_DIR" ]]; then
  echo_err "failed to create temp directory"
  exit 1
fi

cleanup() {
  rm -rf "$TMP_DIR"
}

trap "exit 20" HUP INT PIPE QUIT TERM
trap cleanup EXIT

export SIMVERSE_WORKSPACE=${SIMVERSE_WORKSPACE:-$TMP_DIR/_workspace}
if [[ -n "$SIMVERSE_TEST_REPOS" ]]; then
  export SIMVERSE_REPOS="$SIMVERSE_TEST_REPOS"
else
  export SIMVERSE_REPOS=${SIMVERSE_REPOS:-$TMP_DIR/_repos}
  export SIMVERSE_GIT_REFERENCE_PREFIX=${SIMVERSE_GIT_REFERENCE_PREFIX:-$SIMVERSE_HOME/_repos} # use git references to limit network I/O
fi

cd "$TESTS_DIR"

announce "running tests from '$(pwd -P)'"

./test-cases/01-pay-directly/test.sh b1l2
./test-cases/01-pay-directly/test.sh a1k2

./test-cases/02-pay-via-charlie/test.sh b1l3
./test-cases/02-pay-via-charlie/test.sh a1k3
./test-cases/02-pay-via-charlie/test.sh a1k1l2
./test-cases/02-pay-via-charlie/test.sh a1l1k2
./test-cases/02-pay-via-charlie/test.sh a1k2l1
./test-cases/02-pay-via-charlie/test.sh a1l2k1

# this one is broken with "Incoming htlc(<id>) has an expiration that is too soon" for now
#./test-cases/02-pay-via-charlie/test.sh a1k1b1l2

announce "all tests went OK"