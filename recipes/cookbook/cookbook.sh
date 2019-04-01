#!/usr/bin/env bash

set -e -o pipefail

# this script defines a simple DSL for incrementally building docker-compose config and related files

# recipes must be invoked from $SIMVERSE_HOME/recipes dir, with <simnet_name> and <simverse_workspace> args:

SIMNET_NAME=${1:?please specify a simnet name as first argument}
SIMVERSE_WORKSPACE=${2:?please specify the simverse workspace path as second argument}

# example usage:
#
#    . cookbook/cookbook.sh
#
#    prelude
#    add btcd prague
#    add lnd alice
#    add lnd bob

REQUIRED="variable not set or empty, (hint: source _defaults.sh)"

SIMVERSE_HOME=${SIMVERSE_HOME:?$REQUIRED}
COOKBOOK_DIR="$SIMVERSE_HOME/recipes/cookbook"
TEMPLATES_DIR="$COOKBOOK_DIR/templates"
SCAFFOLD_DIR="$COOKBOOK_DIR/scaffold"
TOOLBOX_DIR="$SIMVERSE_HOME/toolbox"

COMPOSE_FILE="docker-compose.yml"
ALIASES_DIR_NAME="aliases"

# configured externally via env (see _defaults.sh)

FIRST_DLV_PORT_ON_HOST=${FIRST_DLV_PORT_ON_HOST:?$REQUIRED}
FIRST_DLV_PORT=${FIRST_DLV_PORT:?$REQUIRED}

FIRST_LND_SERVER_PORT_ON_HOST=${FIRST_LND_SERVER_PORT_ON_HOST:?$REQUIRED}
FIRST_LND_RPC_PORT_ON_HOST=${FIRST_LND_RPC_PORT_ON_HOST:?$REQUIRED}
FIRST_LND_GRPC_PORT_ON_HOST=${FIRST_LND_GRPC_PORT_ON_HOST:?$REQUIRED}

FIRST_BTCD_SERVER_PORT_ON_HOST=${FIRST_BTCD_SERVER_PORT_ON_HOST:?$REQUIRED}
FIRST_BTCD_RPC_PORT_ON_HOST=${FIRST_BTCD_RPC_PORT_ON_HOST:?$REQUIRED}
FIRST_BTCWALLET_RPC_PORT_ON_HOST=${FIRST_BTCWALLET_RPC_PORT_ON_HOST:?$REQUIRED}

LND_AUTO_NAME_PREFIX=${LND_AUTO_NAME_PREFIX:?$REQUIRED}
BTCD_AUTO_NAME_PREFIX=${BTCD_AUTO_NAME_PREFIX:?$REQUIRED}

DEFAULT_BTCD_REPO_PATH=${DEFAULT_BTCD_REPO_PATH:?$REQUIRED}
DEFAULT_BTCWALLET_REPO_PATH=${DEFAULT_BTCWALLET_REPO_PATH:?$REQUIRED}
DEFAULT_LND_REPO_PATH=${DEFAULT_LND_REPO_PATH:?$REQUIRED}

DEFAULT_BTCD_CONF_PATH=${DEFAULT_BTCD_CONF_PATH:?$REQUIRED}
DEFAULT_BTCWALLET_CONF_PATH=${DEFAULT_BTCWALLET_CONF_PATH:?$REQUIRED}
DEFAULT_LND_CONF_PATH=${DEFAULT_LND_CONF_PATH:?$REQUIRED}

LND_RPC_HOST=${LND_RPC_HOST}

# error codes
NO_ERR=0
ERR_NOT_IMPLEMENTED=10
ERR_MUST_CALL_PRELUDE_FIRST=11
ERR_NEED_BTCD=12

# -- helpers ----------------------------------------------------------------------------------------------------------------

echo_err() {
  printf "\e[31m%s\e[0m\n" "$*" >&2;
}

print_stack_trace() {
  local i=0
  while caller ${i}; do
    ((++i))
  done
}

echo_err_with_stack_trace() {
  echo_err "$@"
  print_stack_trace | tail -n "+2"
}

# -- utils ------------------------------------------------------------------------------------------------------------------

init_common_defaults() {
  local
}

init_btcd_defaults() {
  BTCD_REPO_PATH=${DEFAULT_BTCD_REPO_PATH}
  BTCWALLET_REPO_PATH=${DEFAULT_BTCWALLET_REPO_PATH}
  BTCD_CONF_PATH=${DEFAULT_BTCD_CONF_PATH}
  BTCWALLET_CONF_PATH=${DEFAULT_BTCWALLET_CONF_PATH}
}

init_lnd_defaults() {
  LND_REPO_PATH=${DEFAULT_LND_REPO_PATH}
  LND_CONF_PATH=${DEFAULT_LND_CONF_PATH}
}

init_defaults() {
  init_common_defaults
  init_btcd_defaults
  init_lnd_defaults
}

reset_common_counters() {
  SERVICE_COUNTER=1
  DLV_PORT=${FIRST_DLV_PORT}
  DLV_PORT_ON_HOST=${FIRST_DLV_PORT_ON_HOST}
}

reset_btcd_counters() {
  LAST_BTCD_SERVICE=
  BTCD_COUNTER=1
  BTCD_AUTO_NAME_COUNTER=0
  BTCD_SERVER_PORT_ON_HOST=${FIRST_BTCD_SERVER_PORT_ON_HOST}
  BTCD_RPC_PORT_ON_HOST=${FIRST_BTCD_RPC_PORT_ON_HOST}
  BTCWALLET_RPC_PORT_ON_HOST=${FIRST_BTCWALLET_RPC_PORT_ON_HOST}
}

reset_lnd_counters() {
  LND_COUNTER=1
  LND_AUTO_NAME_COUNTER=0
  LND_SERVER_PORT_ON_HOST=${FIRST_LND_SERVER_PORT_ON_HOST}
  LND_RPC_PORT_ON_HOST=${FIRST_LND_RPC_PORT_ON_HOST}
  LND_GRPC_PORT_ON_HOST=${FIRST_LND_GRPC_PORT_ON_HOST}
}

reset_counters() {
  reset_common_counters
  reset_lnd_counters
  reset_btcd_counters
}

advance_common_counters() {
  ((++SERVICE_COUNTER))
  ((++DLV_PORT))
  ((++DLV_PORT_ON_HOST))
}

advance_btcd_counters() {
  ((++BTCD_COUNTER))
  ((++BTCD_SERVER_PORT_ON_HOST))
  ((++BTCD_RPC_PORT_ON_HOST))
  ((++BTCWALLET_RPC_PORT_ON_HOST))
}

advance_lnd_counters() {
  ((++LND_COUNTER))
  ((++LND_SERVER_PORT_ON_HOST))
  ((++LND_RPC_PORT_ON_HOST))
  ((++LND_GRPC_PORT_ON_HOST))
}

gen_lnd_auto_name() {
  echo "${LND_AUTO_NAME_PREFIX}${LND_AUTO_NAME_COUNTER}"
}

advance_lnd_auto_name_counter() {
  ((++LND_AUTO_NAME_COUNTER))
}

gen_btcd_auto_name() {
  echo "${BTCD_AUTO_NAME_PREFIX}${BTCD_AUTO_NAME_COUNTER}"
}

advance_btcd_auto_name_counter() {
  ((++BTCD_AUTO_NAME_COUNTER))
}

eval_template() {
  local template_file=$1
  eval "cat <<TEMPLATE_EOF_MARKER
$(<${template_file})
TEMPLATE_EOF_MARKER
" 2> /dev/null
}

dolarize() {
  # in template scripts we use double dollar convention for template parameters
  sed 's/\$/>#</g' | sed 's/>#<>#</$/g' | sed 's/`/>##</g'
}

dedolarize() {
  # inverse of dolarize
  sed 's/>#</$/g' | sed 's/>##</`/g'
}

eval_script_template() {
  local template_file=$1
  eval "cat <<TEMPLATE_EOF_MARKER
$(dolarize<${template_file})
TEMPLATE_EOF_MARKER
" | dedolarize 2> /dev/null
}

create_aliases_dir() {
  mkdir "$ALIASES_DIR_NAME"
}

prepare_repos() {
  # the problem is that our docker build context is somewhere $SIMVERSE_HOME/_workspace/[simnetname] (we can have multiple)
  # but we need to access files from $SIMVERSE_HOME/_repos
  # due to security reasons docker does not allow to access files outside that build context
  # here we attempt a fast way how to mount _repos as repos inside the docker context
  case "$OSTYPE" in
    darwin*)
      # -c assumes fast APFS clone
      cp -c -r "$SIMVERSE_HOME/_repos" repos
      ;;
    linux*)
      # TODO: see https://superuser.com/a/842690
      # mkdir -p repos
      # sudo mount --bind "$SIMVERSE_HOME/_repos" repos

      # use slower cp for now...
      cp -r "$SIMVERSE_HOME/_repos" repos
      ;;
    *)
      echo "NOT IMPLEMENTED: add support for mirroring repos inside docker context for $OSTYPE"
      exit ${ERR_NOT_IMPLEMENTED}
      ;;
  esac
}

scaffold_simnet() {
  cp -a "$SCAFFOLD_DIR"/* .
}

add_toolbox() {
  ln -s "$TOOLBOX_DIR" toolbox

}

init_states() {
  mkdir "_states"
  mkdir "_states/master"
  ln -s "_states/master" _volumes
}

echo_service_separator() {
  local kind=$1
  local name=$2
  local counter=$3
  echo -e "\n  # -- ${counter}. $kind service -----------------------------------------------------------" >> ${COMPOSE_FILE}
}

# we have to create stub folders for volumes on host
# if we let docker container create them instead under some systems we could end up with root permissions on them

prepare_pre_volumes() {
  mkdir _volumes/certs
}

prepare_btcd_volumes() {
  local name=$1
  mkdir _volumes/btcd-data-${name}
  mkdir _volumes/btcwallet-data-${name}
}

prepare_lnd_volumes() {
  local name=$1
  mkdir _volumes/lnd-data-${name}
}

add_lnd() {
  NAME=$1

  # generate default name if not given
  if [[ -z "$NAME" ]]; then
    advance_lnd_auto_name_counter
    NAME=$(gen_lnd_auto_name)
  fi

  # auto-provide LND_RPC_HOST if not given
  local prev_lnd_rpc_host="$LND_RPC_HOST"
  if [[ -z "$LND_RPC_HOST" ]]; then
    if [[ -z "$LAST_BTCD_SERVICE" ]]; then
      echo_err_with_stack_trace "'add lnd' called but no prior btcd was added, call 'add btcd' prior adding lnd nodes or set LND_RPC_HOST"
      exit ${ERR_NEED_BTCD}
    fi
    LND_RPC_HOST="$LAST_BTCD_SERVICE"
  fi

  echo_service_separator lnd ${NAME} ${LND_COUNTER}
  eval_template "$TEMPLATES_DIR/lnd.yml" >> ${COMPOSE_FILE}

  local alias_file="$ALIASES_DIR_NAME/$NAME"
  eval_script_template "$TEMPLATES_DIR/lncli-alias.sh" >> "$alias_file"
  chmod +x "$alias_file"

  # point generic lncli to first lnd node
  local default_alias_file="$ALIASES_DIR_NAME/lncli"
  if [[ ! -f "$default_alias_file" ]]; then
    ln -s "$NAME" ${default_alias_file}
  fi

  prepare_lnd_volumes "$NAME"

  advance_common_counters
  advance_lnd_counters

  LND_RPC_HOST="$prev_lnd_rpc_host"
}

add_btcd() {
  NAME=$1

  # generate default name if not given
  if [[ -z "$NAME" ]]; then
    advance_btcd_auto_name_counter
    NAME=$(gen_btcd_auto_name)
  fi

  echo_service_separator btcd ${NAME} ${BTCD_COUNTER}
  eval_template "$TEMPLATES_DIR/btcd.yml" >> ${COMPOSE_FILE}

  local alias_file="$ALIASES_DIR_NAME/$NAME"
  eval_script_template "$TEMPLATES_DIR/btcctl-alias.sh" >> "$alias_file"
  chmod +x "$alias_file"

  # point generic btcctl to first btcd node
  local default_alias_file="$ALIASES_DIR_NAME/btcctl"
  if [[ ! -f "$default_alias_file" ]]; then
    ln -s "$NAME" ${default_alias_file}
  fi

  prepare_btcd_volumes "$NAME"

  advance_common_counters
  advance_btcd_counters

  LAST_BTCD_SERVICE=${NAME}
}

# -- public API -------------------------------------------------------------------------------------------------------------

prelude() {
  scaffold_simnet
  add_toolbox
  create_aliases_dir
  prepare_repos
  init_states
  prepare_pre_volumes
  eval_template "$TEMPLATES_DIR/prelude.yml" > ${COMPOSE_FILE}
  touch docker-compose.yml
  PRELUDE_DONE=1
}

# add [kind] [name] ...
add() {
  local kind=$1
  shift

  # add commands must be called AFTER prelude
  if [[ -z "${PRELUDE_DONE}" ]]; then
    echo_err_with_stack_trace "prelude not called prior calling first add"
    exit ${ERR_MUST_CALL_PRELUDE_FIRST}
  fi

  case "$kind" in
    "btcd") add_btcd "$@" ;;
    "lnd") add_lnd "$@" ;;
    *) echo "unsupported service '$kind', currently allowed are 'btcd' or 'lnd'" ;;
  esac
}

# -- initialization ---------------------------------------------------------------------------------------------------------

init_defaults
reset_counters

cd "$SIMVERSE_WORKSPACE"
if [[ ! -d "$SIMNET_NAME" ]]; then
  mkdir "$SIMNET_NAME"
fi
cd "$SIMNET_NAME"