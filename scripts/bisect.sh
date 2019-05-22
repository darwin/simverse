#!/usr/bin/env bash

set -e -o pipefail

REPO=${1:-bitcoin}
GOOD_REV=${2:?required}
BAD_REV=${3:-HEAD}
TEST_SUITE=${4:-_bisect}

cd "$(dirname "${BASH_SOURCE[0]}")"

SCRIPTS_DIR=$(pwd -P)

cd ..
ROOT_DIR=$(pwd -P)

export SIMVERSE_TEST_REPOS=_repos
exoort SIMVERSE_DEBUG_TEST=

cd "_repos/$REPO"

set -x
git bisect start
git bisect good "$GOOD_REV"
git bisect bad "$BAD_REV"
git bisect run "$ROOT_DIR/tests/run.sh" "$TEST_SUITE"