#!/usr/bin/env bash

. cookbook/cookbook.sh

prelude

BITCOIND_EXTRA_PARAMS='-fallbackfee=0.0007'

add bitcoind


LIGHTNINGD_EXTRA_PARAMS='--ignore-fee-limits=true'
add lightningd alice
mkdir "$SIMVERSE_WORKSPACE/$SIMNET_NAME/_volumes/lightning-data-alice/customplgn" && cp -r "$SIMVERSE_REPOS/plugins/dpchannels" "$SIMVERSE_WORKSPACE/$SIMNET_NAME/_volumes/lightning-data-alice/customplgn/dpchannels"
cp -r "$SIMVERSE_REPOS/plugins/getfixedroute" "$SIMVERSE_WORKSPACE/$SIMNET_NAME/_volumes/lightning-data-alice/customplgn/getfixedroute"


add lightningd bob
mkdir "$SIMVERSE_WORKSPACE/$SIMNET_NAME/_volumes/lightning-data-bob/customplgn" && cp -r "$SIMVERSE_REPOS/plugins/dpchannels" "$SIMVERSE_WORKSPACE/$SIMNET_NAME/_volumes/lightning-data-bob/customplgn/dpchannels"
cp -r "$SIMVERSE_REPOS/plugins/getfixedroute" "$SIMVERSE_WORKSPACE/$SIMNET_NAME/_volumes/lightning-data-bob/customplgn/getfixedroute"

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
connect mallory alice

ALICE_PUBKEY=\$(pubkey alice)
BOB_PUBKEY=\$(pubkey bob)

fund alice 1
fund mallory 1

alice fundchannel id=\${BOB_PUBKEY} amount=100000 push_msat=50000000
mallory fundchannel id=\${ALICE_PUBKEY} amount=150000

generate 6

EOF
chmod +x init