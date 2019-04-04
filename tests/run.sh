#!/usr/bin/env bash

set -e -o pipefail

LAUNCH_DIR=$(pwd -P)

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

TMP_DIR=$(mktemp -d -t simverse_tests)
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
export SIMVERSE_REPOS=${SIMVERSE_REPOS:-$TMP_DIR/_repos}
export SIMVERSE_GIT_REFERENCE_PREFIX=${SIMVERSE_GIT_REFERENCE_PREFIX:-$SIMVERSE_HOME/_repos} # use git references to limit network I/O

cd "$TESTS_DIR"

announce "running tests from '$(pwd -P)'"

./test-cases/tutorial1/test.sh

announce "all tests went OK"