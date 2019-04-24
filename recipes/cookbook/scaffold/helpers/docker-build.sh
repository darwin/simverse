#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")"
. _config.sh

cd "$HELPERS_DIR"

./docker-build-base.sh
./docker-build-buildtime.sh
./docker-build-runtime.sh
