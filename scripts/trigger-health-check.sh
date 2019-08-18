#!/usr/bin/env bash

set -e -o pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

set -x

# update our code to latest
git checkout master
git pull origin

./scripts/health-check-job.sh 2>&1