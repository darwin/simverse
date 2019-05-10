#!/usr/bin/env bash

IFS=$'\n'
read COMMAND

ECLAIR_WALLET_LABEL=eclair

case "$COMMAND" in
  get-chain-height) ./bitcoin-cli.sh -getinfo | jq '.blocks' ;;
  get-new-address) ./bitcoin-cli.sh getnewaddress "$ECLAIR_WALLET_LABEL" bech32 ;;
  get-wallet-balance) ./bitcoin-cli.sh getreceivedbylabel "$ECLAIR_WALLET_LABEL" ;;
  *) echo "unknown command '$COMMAND'" ;;
esac