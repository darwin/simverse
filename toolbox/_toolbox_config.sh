# shellcheck shell=bash

# this is a shell library, it should be sourced by scripts in toolbox

# make sure we use neutral locale, for example printf %f could produce different results based on custom locales
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

export TX_CONF_COUNT=6
export CHANNEL_CONF_COUNT=10
export COINBASE_MATURITY=100
export DOCKER_LOGS_TAIL_COUNT=300
