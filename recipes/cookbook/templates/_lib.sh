#!/usr/bin/env bash

SIMVERSE_DONT_BEAUTIFY_ALIASES=${SIMVERSE_DONT_BEAUTIFY_ALIASES}

beautify_if_needed() {
  local first_line
  read -r first_line
  if [[ -n "$SIMVERSE_DONT_BEAUTIFY_ALIASES" || "$first_line" != "{"* ]]; then
    echo "$first_line"; cat -
  else
    ( echo "$first_line"; cat - ) | jq
  fi
}
