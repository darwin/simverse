#!/usr/bin/env bash

RECIPES_DIR="$(dirname "${BASH_SOURCE[0]}")"

. "$RECIPES_DIR/cookbook/cookbook.sh" || true || . cookbook/cookbook.sh

prelude

add btcd

add lnd alice
add lnd bob