#!/usr/bin/env bash

. cookbook/cookbook.sh

prelude

add bitcoind


LIGHTNINGD_EXTRA_PARAMS='--plugin=/home/simnet/.lightning/customplgn/sloppy/sloppy.py --ignore-fee-limits=true'
add lightningd alice
mkdir "$SIMVERSE_WORKSPACE/$SIMNET_NAME/_volumes/lightning-data-alice/customplgn" && cp -r "$SIMVERSE_REPOS/plugins/sloppy" "$SIMVERSE_WORKSPACE/$SIMNET_NAME/_volumes/lightning-data-alice/customplgn/sloppy"


add lightningd bob
mkdir "$SIMVERSE_WORKSPACE/$SIMNET_NAME/_volumes/lightning-data-bob/customplgn" && cp -r "$SIMVERSE_REPOS/plugins/sloppy" "$SIMVERSE_WORKSPACE/$SIMNET_NAME/_volumes/lightning-data-bob/customplgn/sloppy"

LIGHTNINGD_EXTRA_PARAMS='--ignore-fee-limits=true'
add lightningd charlie

add lightningd dave

LIGHTNINGD_EXTRA_PARAMS='--plugin=/home/simnet/.lightning/customplgn/getfixedroute/getfixedroute.py --plugin=/home/simnet/.lightning/customplgn/bda/bda.py --ignore-fee-limits=true'
add lightningd mallory
mkdir "$SIMVERSE_WORKSPACE/$SIMNET_NAME/_volumes/lightning-data-mallory/customplgn" && cp -r "$SIMVERSE_REPOS/plugins/getfixedroute" "$SIMVERSE_WORKSPACE/$SIMNET_NAME/_volumes/lightning-data-mallory/customplgn/getfixedroute"
cp -r "$SIMVERSE_REPOS/plugins/bda" "$SIMVERSE_WORKSPACE/$SIMNET_NAME/_volumes/lightning-data-mallory/customplgn/bda"

# generate init script to build connections
cat > init <<EOF
#!/usr/bin/env bash

set -e -o pipefail

# connect LN nodes
connect alice bob
connect bob dave
connect charlie bob
connect alice bob
connect mallory alice

ALICE_PUBKEY=\$(pubkey alice)
BOB_PUBKEY=\$(pubkey bob)
CHARLIE_PUBKEY=\$(pubkey charlie)
DAVE_PUBKEY=\$(pubkey dave)

fund alice 1
fund bob 1
fund bob 1
fund charlie 1
fund mallory 1

dave fundchannel id=\${BOB_PUBKEY} amount=100000 push_msat=50000000
bob fundchannel id=\${ALICE_PUBKEY} amount=100000 push_msat=1020000
bob fundchannel id=\${CHARLIE_PUBKEY} amount=100000 push_msat=1030000
alice fundchannel id=\${CHARLIE_PUBKEY} amount=100000
mallory fundchannel id=\${ALICE_PUBKEY} amount=100000

generate 6
EOF
chmod +x init