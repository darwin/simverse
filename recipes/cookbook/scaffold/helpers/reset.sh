#!/usr/bin/env bash

. "$(dirname "${BASH_SOURCE[0]}")/_config.sh" || true || . _config.sh

cd "$THIS_DIR"

if [[ -d "$VOLUMES_DIR" && -n "$VOLUMES_DIR" ]]; then
  rm -rf "$VOLUMES_DIR"/*
fi

mkdir -p "$VOLUMES_DIR/master"