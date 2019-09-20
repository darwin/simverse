#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")"

./../cases/01-pay-directly/test.sh a1k2
./../cases/01-pay-directly/test.sh b1l2
#./../cases/01-pay-directly/test.sh a1m2
./../cases/01-pay-directly/test.sh a1l2 # https://github.com/darwin/simverse/issues/7