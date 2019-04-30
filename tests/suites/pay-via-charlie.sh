#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")"

./../test-cases/02-pay-via-charlie/test.sh b1l3
./../test-cases/02-pay-via-charlie/test.sh a1k3

./../test-cases/02-pay-via-charlie/test.sh a1l1a1l2
./../test-cases/02-pay-via-charlie/test.sh a1k1a1k2
