#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")"

./../cases/01-pay-directly/test.sh a1m2
./../cases/02-pay-via-charlie/test.sh a1m3