#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/ansi.sh"

report() {
  echo "${blue}> $*${normal}"
  "$@"
}

if [[ -n "$REPORT_ENV" ]]; then
  echo
  echo "Environment report:"
  report uname -a
  report whoami
  report env
  report tree -pug /home
  echo
fi