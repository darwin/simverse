#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")"

./../cases/02-pay-via-charlie/test.sh a1k1l2
./../cases/02-pay-via-charlie/test.sh a1l1k2
./../cases/02-pay-via-charlie/test.sh a1k2l1
./../cases/02-pay-via-charlie/test.sh a1l2k1

./../cases/02-pay-via-charlie/test.sh a1k1a1l2

# this one is broken with "Incoming htlc(<id>) has an expiration that is too soon" for now
#./../cases/02-pay-via-charlie/test.sh a1k1b1l2
