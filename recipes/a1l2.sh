#!/usr/bin/env bash

# in this recipe we use bitcoind instead of btcd, see b1l2.sh

. cookbook/cookbook.sh

prelude

add bitcoind

add lnd alice
add lnd bob