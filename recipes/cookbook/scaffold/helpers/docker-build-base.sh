#!/usr/bin/env bash

. "$(dirname "${BASH_SOURCE[0]}")/_config.sh" || true || . _config.sh

cd "$DOCKER_DIR/_aux/base"

SIMVERSE_HOST_UID=${SIMVERSE_HOST_UID:?required}
SIMVERSE_HOST_GID=${SIMVERSE_HOST_GID:?required}

docker build -t "$BASE_DOCKER_IMAGE_NAME" \
  --build-arg SIMVERSE_HOST_UID=${SIMVERSE_HOST_UID} \
  --build-arg SIMVERSE_HOST_GID=${SIMVERSE_HOST_GID} \
.
