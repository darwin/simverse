#!/usr/bin/env bash

# standard bash switches for our scripts
set -e -o pipefail

pushd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null

. "lib/utils.sh"

cd ..

THIS_DIR=$(pwd -P)

HELPERS_DIR="$THIS_DIR/helpers"
DOCKER_DIR="$THIS_DIR/docker"
VOLUMES_DIR="$THIS_DIR/_volumes"

popd
