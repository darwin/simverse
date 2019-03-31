#!/usr/bin/env bash

. "$(dirname "${BASH_SOURCE[0]}")/_config.sh" || true || . _config.sh

cd "$HELPERS_DIR"

./docker-build-builder.sh
./docker-build-base.sh