#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")"

cd ".."

SIMVERSE_VERBOSE_ALIASES=${SIMVERSE_VERBOSE_ALIASES}

if [[ -n "$SIMVERSE_VERBOSE_ALIASES" ]]; then
  [[ -t 1 ]] && echo ">" "$(basename "$0")" "$@"
fi

exec ./dc exec "$$NAME" lightning-cli.sh "$@"

