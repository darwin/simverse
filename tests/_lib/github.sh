#!/usr/bin/env bash

# https://github.community/t5/GitHub-Actions/Has-github-action-somthing-like-travis-fold/m-p/37715

github_section() {
  local action=$1
  if [[ "$action" == "start" ]]; then
    echo "::group::${*:3}"
  else
    echo "::endgroup::"
  fi
}
