#!/usr/bin/env bash

source lib/init.sh
source lib/utils.sh

CONTAINER_NAME=${CONTAINER_NAME:?required}

cmd="[[ \$(lncli.sh getinfo | jq \".synced_to_chain\") == \"true\" ]]"
wait_for "$CONTAINER_NAME to sync" "$cmd"

signal_service_ready