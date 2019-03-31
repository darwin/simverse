#!/usr/bin/env bash

. "$(dirname "${BASH_SOURCE[0]}")/_config.sh" || true || . _config.sh

cd "$DOCKER_DIR/_aux/builder"

docker build --build-arg GCFLAGS="$GCFLAGS" -t "$BUILDER_DOCKER_IMAGE_NAME" .
