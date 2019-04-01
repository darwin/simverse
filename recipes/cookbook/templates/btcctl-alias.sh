#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")"

cd ".."

exec docker-compose exec "$$NAME" btcctl.sh "$@"

