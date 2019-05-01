#!/usr/bin/env bash

IFS=$'\n'
read COMMAND

case "$COMMAND" in
  get-chain-height) ./bitcoin-cli.sh -getinfo | jq '.blocks' ;;
  *) echo "unknown command '$COMMAND'" ;;
esac