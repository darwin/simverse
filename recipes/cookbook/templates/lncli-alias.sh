#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")"

cd ".."

exec ./dc exec "$$NAME" lncli.sh "$@"

