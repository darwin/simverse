#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")"
. _config.sh

cd "$DOCKER_DIR/_aux/buildtime"

docker build --build-arg GCFLAGS="$GCFLAGS" -t "$BUILDTIME_DOCKER_IMAGE_NAME" .
