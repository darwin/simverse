#!/usr/bin/env bash

. "$(dirname "${BASH_SOURCE[0]}")/_config.sh" || true || . _config.sh

cd "$DOCKER_DIR/_aux/base"

docker build -t "$BASE_DOCKER_IMAGE_NAME" .
