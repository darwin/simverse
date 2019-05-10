#!/usr/bin/env bash

set -e -o pipefail

TEST_SUITE=${1:-default}

LAUNCH_DIR=$(pwd -P)

SIMVERSE_DEBUG_TEST=${SIMVERSE_DEBUG_TEST}
SIMVERSE_TEST_REPOS=${SIMVERSE_TEST_REPOS}

cd "$(dirname "${BASH_SOURCE[0]}")"

TESTS_DIR="$(pwd -P)"

source ../toolbox/_lib.sh
source _lib/helpers.sh

cd ..

export SIMVERSE_HOME="$(pwd -P)"

SIMVERSE_TEST_TMP=${SIMVERSE_TEST_TMP}
if [[ -n "$SIMVERSE_TEST_TMP" ]]; then
  TMP_DIR="$SIMVERSE_TEST_TMP/simverse-tests"
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

announce "running [$TEST_SUITE] tests from '$(pwd -P)'"

# echo alias commands during tests
export SIMVERSE_VERBOSE_ALIASES=1

. "suites/$TEST_SUITE.sh"

announce "all tests went OK"