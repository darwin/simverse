#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")"

source _lib.sh

cd ".."

echo_command_if_needed "$@"
DC_EXEC_EXTRA_ARGS=$(prepare_docker_compose_exec_args)
exec docker-compose exec ${DC_EXEC_EXTRA_ARGS} "$$NAME" bitcoin-cli.sh "$@" | beautify_if_needed
