#!/usr/bin/env bash

set -e -o pipefail

# this script defines a simple DSL for incrementally building docker-compose config and related files

# recipes must be invoked from $SIMVERSE_HOME/recipes dir, with <simnet_name>
#
# also note that SIMVERSE_HOME, SIMVERSE_WORKSPACE and SIMVERSE_REPOS must be set

SIMNET_NAME=${1:?please specify a simnet name as first argument}

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
SIMVERSE_REPOS=${SIMVERSE_REPOS:?$REQUIRED}
SIMVERSE_WORKSPACE=${SIMVERSE_WORKSPACE:?$REQUIRED}
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
FIRST_LND_REST_PORT_ON_HOST=${FIRST_LND_REST_PORT_ON_HOST:?$REQUIRED}
FIRST_BTCD_SERVER_PORT_ON_HOST=${FIRST_BTCD_SERVER_PORT_ON_HOST:?$REQUIRED}
FIRST_BTCD_RPC_PORT_ON_HOST=${FIRST_BTCD_RPC_PORT_ON_HOST:?$REQUIRED}
FIRST_BTCWALLET_RPC_PORT_ON_HOST=${FIRST_BTCWALLET_RPC_PORT_ON_HOST:?$REQUIRED}
FIRST_BITCOIND_SERVER_PORT_ON_HOST=${FIRST_BITCOIND_SERVER_PORT_ON_HOST:?$REQUIRED}
FIRST_BITCOIND_RPC_PORT_ON_HOST=${FIRST_BITCOIND_RPC_PORT_ON_HOST:?$REQUIRED}
FIRST_LIGHTNING_SERVER_PORT_ON_HOST=${FIRST_LIGHTNING_SERVER_PORT_ON_HOST:?$REQUIRED}
FIRST_LIGHTNING_RPC_PORT_ON_HOST=${FIRST_LIGHTNING_RPC_PORT_ON_HOST:?$REQUIRED}

LND_AUTO_NAME_PREFIX=${LND_AUTO_NAME_PREFIX:?$REQUIRED}
BTCD_AUTO_NAME_PREFIX=${BTCD_AUTO_NAME_PREFIX:?$REQUIRED}
BITCOIND_AUTO_NAME_PREFIX=${BITCOIND_AUTO_NAME_PREFIX:?$REQUIRED}
LIGHTNING_AUTO_NAME_PREFIX=${LIGHTNING_AUTO_NAME_PREFIX:?$REQUIRED}

DEFAULT_BTCD_REPO_PATH=${DEFAULT_BTCD_REPO_PATH:?$REQUIRED}
DEFAULT_BTCWALLET_REPO_PATH=${DEFAULT_BTCWALLET_REPO_PATH:?$REQUIRED}
DEFAULT_LND_REPO_PATH=${DEFAULT_LND_REPO_PATH:?$REQUIRED}
DEFAULT_BITCOIND_REPO_PATH=${DEFAULT_BITCOIND_REPO_PATH:?$REQUIRED}
DEFAULT_LIGHTNING_REPO_PATH=${DEFAULT_LIGHTNING_REPO_PATH:?$REQUIRED}

DEFAULT_BTCD_CONF_PATH=${DEFAULT_BTCD_CONF_PATH:?$REQUIRED}
DEFAULT_BTCWALLET_CONF_PATH=${DEFAULT_BTCWALLET_CONF_PATH:?$REQUIRED}
DEFAULT_LND_CONF_PATH=${DEFAULT_LND_CONF_PATH:?$REQUIRED}
DEFAULT_BITCOIND_CONF_PATH=${DEFAULT_BITCOIND_CONF_PATH:?$REQUIRED}
DEFAULT_LIGHTNING_CONF_PATH=${DEFAULT_LIGHTNING_CONF_PATH:?$REQUIRED}

LND_BITCOIN_RPC_HOST=${LND_BITCOIN_RPC_HOST}
LND_BACKEND=${LND_BACKEND}

LIGHTNING_BITCOIN_RPC_HOST=${LIGHTNING_BITCOIN_RPC_HOST}
LIGHTNING_BACKEND=${LIGHTNING_BACKEND}

# error codes
NO_ERR=0
ERR_NOT_IMPLEMENTED=10
ERR_MUST_CALL_PRELUDE_FIRST=11
ERR_NEED_BTCD_OR_BITCOIND=12
ERR_REQUIRE_BITCOIND=13

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

init_bitcoind_defaults() {
  BITCOIND_REPO_PATH=${DEFAULT_BITCOIND_REPO_PATH}
  BITCOIND_CONF_PATH=${DEFAULT_BITCOIND_CONF_PATH}
}

init_lightning_defaults() {
  LIGHTNING_REPO_PATH=${DEFAULT_LIGHTNING_REPO_PATH}
  LIGHTNING_CONF_PATH=${DEFAULT_LIGHTNING_CONF_PATH}
}
init_defaults() {
  init_common_defaults
  init_btcd_defaults
  init_lnd_defaults
  init_bitcoind_defaults
  init_lightning_defaults
}

reset_common_counters() {
  SERVICE_COUNTER=1
  BITCOIN_COUNTER=1
  LN_COUNTER=1
  DLV_PORT=${FIRST_DLV_PORT}
  DLV_PORT_ON_HOST=${FIRST_DLV_PORT_ON_HOST}
  LAST_BITCOIN_SERVICE=
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
  LND_REST_PORT_ON_HOST=${FIRST_LND_REST_PORT_ON_HOST}
}

reset_bitcoind_counters() {
  LAST_BITCOIND_SERVICE=
  BITCOIND_COUNTER=1
  BITCOIND_AUTO_NAME_COUNTER=0
  BITCOIND_SERVER_PORT_ON_HOST=${FIRST_BITCOIND_SERVER_PORT_ON_HOST}
  BITCOIND_RPC_PORT_ON_HOST=${FIRST_BITCOIND_RPC_PORT_ON_HOST}
}

reset_lightning_counters() {
  LIGHTNING_COUNTER=1
  LIGHTNING_AUTO_NAME_COUNTER=0
  LIGHTNING_SERVER_PORT_ON_HOST=${FIRST_LIGHTNING_SERVER_PORT_ON_HOST}
  LIGHTNING_RPC_PORT_ON_HOST=${FIRST_LIGHTNING_RPC_PORT_ON_HOST}
}

reset_counters() {
  reset_common_counters
  reset_lnd_counters
  reset_btcd_counters
  reset_bitcoind_counters
  reset_lightning_counters
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

  ((++BITCOIN_COUNTER))
}

advance_lnd_counters() {
  ((++LND_COUNTER))
  ((++LND_SERVER_PORT_ON_HOST))
  ((++LND_RPC_PORT_ON_HOST))
  ((++LND_REST_PORT_ON_HOST))

  ((++LN_COUNTER))
}

advance_bitcoind_counters() {
  ((++BITCOIND_COUNTER))
  ((++BITCOIND_SERVER_PORT_ON_HOST))
  ((++BITCOIND_RPC_PORT_ON_HOST))

  ((++BITCOIN_COUNTER))
}

advance_lightning_counters() {
  ((++LIGHTNING_COUNTER))
  ((++LIGHTNING_SERVER_PORT_ON_HOST))
  ((++LIGHTNING_RPC_PORT_ON_HOST))

  ((++LN_COUNTER))
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

gen_bitcoind_auto_name() {
  echo "${BITCOIND_AUTO_NAME_PREFIX}${BITCOIND_AUTO_NAME_COUNTER}"
}

advance_bitcoind_auto_name_counter() {
  ((++BITCOIND_AUTO_NAME_COUNTER))
}

gen_lightning_auto_name() {
  echo "${LIGHTNING_AUTO_NAME_PREFIX}${LIGHTNING_AUTO_NAME_COUNTER}"
}

advance_lightning_auto_name_counter() {
  ((++LIGHTNING_AUTO_NAME_COUNTER))
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
      cp -c -r "$SIMVERSE_REPOS" repos
      ;;
    linux*)
      # TODO: see https://superuser.com/a/842690
      # mkdir -p repos
      # sudo mount --bind "$SIMVERSE_REPOS" repos

      # use slower cp for now...
      cp -r "$SIMVERSE_REPOS" repos
      ;;
    *)
      echo "NOT IMPLEMENTED: add support for mirroring repos inside docker context for $OSTYPE"
      exit ${ERR_NOT_IMPLEMENTED}
      ;;
  esac
}

scaffold_simnet() {
  # copy including dot files
  shopt -s dotglob
  cp -a "$SCAFFOLD_DIR"/* .
  shopt -u dotglob
}

add_toolbox() {
  ln -s "$TOOLBOX_DIR" toolbox

}

init_states() {
  mkdir "_states"
  mkdir "_states/master"
  ln -s "_states/master" _volumes
}

prepare_tmux_script() {
  eval_script_template "$TEMPLATES_DIR/tmux" > "tmux"
  chmod +x "tmux"
}

prepare_home_link() {
  ln -s "$SIMVERSE_HOME" home
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
  local name=${1:?required}
  mkdir _volumes/btcd-data-${name}
  mkdir _volumes/btcwallet-data-${name}
}

prepare_lnd_volumes() {
  local name=${1:?required}
  mkdir _volumes/lnd-data-${name}
}

prepare_bitcoind_volumes() {
  local name=${1:?required}
  mkdir _volumes/bitcoind-data-${name}
}

prepare_lightning_volumes() {
  local name=${1:?required}
  mkdir _volumes/lightning-data-${name}
}

ensure_bitcoin_service() {
  if [[ -z "$LAST_BITCOIN_SERVICE" ]]; then
    echo_err_with_stack_trace "'add lnd' called but no prior btcd or bitcoind was added, call 'add btcd' or 'add bitcoind' prior adding lnd nodes or set LND_BITCOIN_RPC_HOST explicitly"
    exit ${ERR_NEED_BTCD_OR_BITCOIND}
  fi
}

get_last_bitcoin_service() {
  ensure_bitcoin_service
  echo "$LAST_BITCOIN_SERVICE"
}

get_last_bitcoin_backend() {
  ensure_bitcoin_service
  if [[ "$LAST_BITCOIN_SERVICE" == "$LAST_BITCOIND_SERVICE" ]]; then
    echo "bitcoind"
    return
  fi
  echo "btcd"
}

add_lnd() {
  NAME=$1

  # generate default name if not given
  if [[ -z "$NAME" ]]; then
    advance_lnd_auto_name_counter
    NAME=$(gen_lnd_auto_name)
  fi

  # auto-provide LND_BITCOIN_RPC_HOST if not given
  local prev_lnd_bitcoin_rpc_host="$LND_BITCOIN_RPC_HOST"
  if [[ -z "$LND_BITCOIN_RPC_HOST" ]]; then
    LND_BITCOIN_RPC_HOST="$(get_last_bitcoin_service)"
  fi
  local prev_lnd_backend="$LND_BACKEND"
  if [[ -z "$LND_BACKEND" ]]; then
    LND_BACKEND="$(get_last_bitcoin_backend)"
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

  LND_BITCOIN_RPC_HOST="$prev_lnd_bitcoin_rpc_host"
  LND_BACKEND="$prev_lnd_backend"
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
  LAST_BITCOIN_SERVICE=${LAST_BTCD_SERVICE}
}

add_bitcoind() {
  NAME=$1

  # generate default name if not given
  if [[ -z "$NAME" ]]; then
    advance_bitcoind_auto_name_counter
    NAME=$(gen_bitcoind_auto_name)
  fi

  echo_service_separator bitcoind ${NAME} ${BITCOIND_COUNTER}
  eval_template "$TEMPLATES_DIR/bitcoind.yml" >> ${COMPOSE_FILE}

  local alias_file="$ALIASES_DIR_NAME/$NAME"
  eval_script_template "$TEMPLATES_DIR/bitcoin-cli-alias.sh" >> "$alias_file"
  chmod +x "$alias_file"

  # point generic bitcoin-cli to first bitcoind node
  local default_alias_file="$ALIASES_DIR_NAME/bitcoin-cli"
  if [[ ! -f "$default_alias_file" ]]; then
    ln -s "$NAME" ${default_alias_file}
  fi

  prepare_bitcoind_volumes "$NAME"

  advance_common_counters
  advance_bitcoind_counters

  LAST_BITCOIND_SERVICE=${NAME}
  LAST_BITCOIN_SERVICE=${LAST_BITCOIND_SERVICE}
}

add_lightning() {
  NAME=$1

  # generate default name if not given
  if [[ -z "$NAME" ]]; then
    advance_lightning_auto_name_counter
    NAME=$(gen_lightning_auto_name)
  fi

  # auto-provide LIGHTNING_BITCOIN_RPC_HOST if not given
  local prev_lightning_bitcoin_rpc_host="$LIGHTNING_BITCOIN_RPC_HOST"
  if [[ -z "$LIGHTNING_BITCOIN_RPC_HOST" ]]; then
    LIGHTNING_BITCOIN_RPC_HOST="$(get_last_bitcoin_service)"
  fi
  local prev_lightning_backend="$LIGHTNING_BACKEND"
  if [[ -z "$LIGHTNING_BACKEND" ]]; then
    LIGHTNING_BACKEND="$(get_last_bitcoin_backend)"
    if [[ "$LIGHTNING_BACKEND" != "bitcoind" ]]; then
      echo_err "lightning node '$NAME' needs bitcoind backend, add at least one bitcoind before adding lightning nodes"
      exit ${ERR_REQUIRE_BITCOIND}
    fi
  fi

  echo_service_separator lightning ${NAME} ${LIGHTNING_COUNTER}
  eval_template "$TEMPLATES_DIR/lightning.yml" >> ${COMPOSE_FILE}

  local alias_file="$ALIASES_DIR_NAME/$NAME"
  eval_script_template "$TEMPLATES_DIR/lightning-cli-alias.sh" >> "$alias_file"
  chmod +x "$alias_file"

  # point generic lightning-cli to the first lightning node
  local default_alias_file="$ALIASES_DIR_NAME/lightning-cli"
  if [[ ! -f "$default_alias_file" ]]; then
    ln -s "$NAME" ${default_alias_file}
  fi

  prepare_lightning_volumes "$NAME"

  advance_common_counters
  advance_lightning_counters

  LIGHTNING_BITCOIN_RPC_HOST="$prev_lightning_bitcoin_rpc_host"
  LIGHTNING_BACKEND="$prev_lightning_backend"
}

# -- public API -------------------------------------------------------------------------------------------------------------

prelude() {
  scaffold_simnet
  add_toolbox
  create_aliases_dir
  prepare_repos
  init_states
  prepare_pre_volumes
  prepare_tmux_script
  prepare_home_link
  eval_template "$TEMPLATES_DIR/prelude.yml" > ${COMPOSE_FILE}
  touch docker-compose.yml
  PRELUDE_DONE=1
}

# add [flavor] [name] ...
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
    "bitcoind") add_bitcoind "$@" ;;
    "lightningd"|"lightning"|"c-lightning") add_lightning "$@" ;;
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