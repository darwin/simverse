#!/usr/bin/env bash

# simverse workspace can be located outside this repo checkout
export SIMVERSE_WORKSPACE=${SIMVERSE_WORKSPACE:-_workspace}

# simverse repos can be located outside this repo checkout
export SIMVERSE_REPOS=${SIMVERSE_REPOS:-_repos}

#############################################################################################################################
# big-bang-time defaults, effective during ./sv create (or other commands)

export SIMVERSE_DOCKER_IMAGE_PREFIX="sv_"
export SIMVERSE_DOCKER_NETWORK_PREFIX="$SIMVERSE_DOCKER_IMAGE_PREFIX"
export SIMVERSE_DOCKER_CONTAINER_PREFIX=""

export DEFAULT_SIMNET_NAME=${DEFAULT_SIMNET_NAME:-default}
export DEFAULT_RECIPE_NAME=${DEFAULT_RECIPE_NAME:-default}
export DEFAULT_STATE_NAME=${DEFAULT_STATE_NAME:-master}

export SIMVERSE_GIT_CLONE_OPTS="--depth=1 --recursive"
export SIMVERSE_GIT_FETCH_OPTS=""
export SIMVERSE_GIT_PULL_OPTS=""

export SIMVERSE_BTCD_REPO_URL="https://github.com/btcsuite/btcd.git"
export SIMVERSE_BTCWALLET_REPO_URL="https://github.com/btcsuite/btcwallet.git"
export SIMVERSE_LND_REPO_URL="https://github.com/lightningnetwork/lnd.git"

export FIRST_DLV_PORT_ON_HOST=${FIRST_DLV_PORT_ON_HOST:-41000}
export FIRST_DLV_PORT=${FIRST_DLV_PORT:-41000}

export SIMVERSE_PRE_SIGNAL_PORT=${SIMVERSE_PRE_SIGNAL_PORT:-55123}
export SIMVERSE_PRE_SIGNAL_PORT_ON_HOST=${SIMVERSE_PRE_SIGNAL_PORT_ON_HOST:-$SIMVERSE_PRE_SIGNAL_PORT}

export FIRST_LND_SERVER_PORT_ON_HOST=${FIRST_LND_SERVER_PORT_ON_HOST:-10000}
export FIRST_LND_RPC_PORT_ON_HOST=${FIRST_LND_RPC_PORT_ON_HOST:-10300}
export FIRST_LND_GRPC_PORT_ON_HOST=${FIRST_LND_GRPC_PORT_ON_HOST:-10600}

export FIRST_BTCWALLET_RPC_PORT_ON_HOST=${FIRST_BTCWALLET_RPC_PORT_ON_HOST:-12000}
export FIRST_BTCD_SERVER_PORT_ON_HOST=${FIRST_BTCD_SERVER_PORT_ON_HOST:-12300}
export FIRST_BTCD_RPC_PORT_ON_HOST=${FIRST_BTCD_RPC_PORT_ON_HOST:-12600}

export LND_AUTO_NAME_PREFIX=${LND_AUTO_NAME_PREFIX:-lnd}
export BTCD_AUTO_NAME_PREFIX=${BTCD_AUTO_NAME_PREFIX:-btcd}

# ---------------------------------------------------------------------------------------------------------------------------
# note: these are relative to docker build context

export DEFAULT_BTCD_REPO_PATH=${DEFAULT_BTCD_REPO_PATH:-repos/btcd}
export DEFAULT_BTCWALLET_REPO_PATH=${DEFAULT_BTCWALLET_REPO_PATH:-repos/btcwallet}
export DEFAULT_LND_REPO_PATH=${DEFAULT_LND_REPO_PATH:-repos/lnd}

export DEFAULT_BTCD_CONF_PATH=${DEFAULT_BTCD_CONF_PATH:-docker/btcd/btcd.conf}
export DEFAULT_BTCWALLET_CONF_PATH=${DEFAULT_BTCWALLET_CONF_PATH:-docker/btcd/btcwallet.conf}
export DEFAULT_LND_CONF_PATH=${DEFAULT_LND_CONF_PATH:-docker/lnd/lnd.conf}

#############################################################################################################################
# build-time/run-time defaults, effective during building or running docker containers via ./dc

# you can tweak these on per-node basis in your recipes
export RPC_USER=devuser
export RPC_PASS=devpass
export DEBUG=info
export NETWORK=simnet
export BTCD_LISTEN=0.0.0.0
export BTCD_RPC_LISTEN=0.0.0.0
export BTCD_EXTRA_PARAMS=
export BTCD_MINING_ADDR=SNkMM96QQE6QLsbtivfePb4ztkPZTMq8L9 # note this is a simnet address
export BTCD_MINING_ADDR_PK=FwKY4zwscP47RKYWjiDJZxUTbWcyXRXvrAhQ2iLEuJXcRiLa7tYy # note this is a simnet key
export BTCWALLET_EXTRA_PARAMS=
export BTCWALLET_RPC_LISTEN=0.0.0.0
export BTCWALLET_USER=
export BTCWALLET_PASS=
export LND_EXTRA_PARAMS=
export LND_CHAIN=bitcoin
export LND_BACKEND=btcd
export LND_RPC_LISTEN=0.0.0.0
export LND_RPC_HOST=
export LND_LISTEN=0.0.0.0
export BTCCTL_EXTRA_PARAMS=

# GO specific
export GCFLAGS="all=-N -l" # compile with no optimizations, for go-delve debugger