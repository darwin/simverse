#!/usr/bin/env bash

source lib/init.sh

# this is a simple server for other containers to talk to our node
CONTAINER_SERVICE_PORT=${CONTAINER_SERVICE_PORT:?required}
exec nc -nlk -p "$CONTAINER_SERVICE_PORT" -e ~/container-service.sh
