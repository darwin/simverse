#!/usr/bin/env bash

set -e -o pipefail

THIS_SCRIPT="${BASH_SOURCE[0]}"

cd "$(dirname "$THIS_SCRIPT")/.."

echo "-----------------------------------------------------------------------------------------------------------------------"
echo "running $THIS_SCRIPT on $(date)"

HEALTH_CHECK_DRY_RUN=${HEALTH_CHECK_DRY_RUN}

echo "ENVIRONMENT:"
env

finish () {
  # return to master branch
  git checkout master
  echo "finished $THIS_SCRIPT on $(date)"
  echo
  echo
}
trap finish EXIT

set -x

# configure repo
git config user.email "bot@binaryage.com"
git config user.name "BinaryAge Bot"

git fetch origin

# checkout or create health-check branch
git checkout -B health-check origin/master

# merge all changes from origin/master to health-check
git merge --no-edit --no-verify-signatures -Xtheirs -m "merge new work" origin/master

# commit an empty commit to trigger travis build
git commit --allow-empty -F- << EOF
check Simverse health on $(date)
EOF

if [[ -z "$HEALTH_CHECK_DRY_RUN" ]]; then
  git push --force origin health-check
else
  echo "not pushing because HEALTH_CHECK_DRY_RUN is set"
fi