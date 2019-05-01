#!/usr/bin/env bash

IFS=$'\n'
read COMMAND

case "$COMMAND" in
  get-chain-height) ./btcctl.sh -getinfo | jq '.blocks' ;;
  *) echo "unknown command '$COMMAND'" ;;
esac