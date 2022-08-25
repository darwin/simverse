#!/usr/bin/env bash

. cookbook/cookbook.sh

prelude

add bitcoind


LIGHTNINGD_EXTRA_PARAMS='--plugin=/home/simnet/.lightning/customplgn/getfixedroute/getfixedroute.py --ignore-fee-limits=true'
add lightningd alice
mkdir "$SIMVERSE_WORKSPACE/$SIMNET_NAME/_volumes/lightning-data-alice/customplgn" && cp -r "$SIMVERSE_REPOS/plugins/dpchannels" "$SIMVERSE_WORKSPACE/$SIMNET_NAME/_volumes/lightning-data-alice/customplgn/dpchannels"
cp -r "$SIMVERSE_REPOS/plugins/getfixedroute" "$SIMVERSE_WORKSPACE/$SIMNET_NAME/_volumes/lightning-data-alice/customplgn/getfixedroute"


add lightningd bob
mkdir "$SIMVERSE_WORKSPACE/$SIMNET_NAME/_volumes/lightning-data-bob/customplgn" && cp -r "$SIMVERSE_REPOS/plugins/dpchannels" "$SIMVERSE_WORKSPACE/$SIMNET_NAME/_volumes/lightning-data-bob/customplgn/dpchannels"
cp -r "$SIMVERSE_REPOS/plugins/getfixedroute" "$SIMVERSE_WORKSPACE/$SIMNET_NAME/_volumes/lightning-data-bob/customplgn/getfixedroute"

add lightningd charlie
mkdir "$SIMVERSE_WORKSPACE/$SIMNET_NAME/_volumes/lightning-data-charlie/customplgn" && cp -r "$SIMVERSE_REPOS/plugins/dpchannels" "$SIMVERSE_WORKSPACE/$SIMNET_NAME/_volumes/lightning-data-charlie/customplgn/dpchannels"
cp -r "$SIMVERSE_REPOS/plugins/getfixedroute" "$SIMVERSE_WORKSPACE/$SIMNET_NAME/_volumes/lightning-data-charlie/customplgn/getfixedroute"

LIGHTNINGD_EXTRA_PARAMS='--plugin=/home/simnet/.lightning/customplgn/getfixedroute/getfixedroute.py --plugin=/home/simnet/.lightning/customplgn/bda/bda.py'
add lightningd mallory
mkdir "$SIMVERSE_WORKSPACE/$SIMNET_NAME/_volumes/lightning-data-mallory/customplgn" && cp -r "$SIMVERSE_REPOS/plugins/getfixedroute" "$SIMVERSE_WORKSPACE/$SIMNET_NAME/_volumes/lightning-data-mallory/customplgn/getfixedroute"
cp -r "$SIMVERSE_REPOS/plugins/bda" "$SIMVERSE_WORKSPACE/$SIMNET_NAME/_volumes/lightning-data-mallory/customplgn/bda"

LIGHTNINGD_EXTRA_PARAMS='--ignore-fee-limits=true'

add lightningd alice_loopnode
add lightningd bob_loopnode
add lightningd charlie_loopnode

# generate init script to build connections
cat > init <<EOF
#!/usr/bin/env bash

set -e -o pipefail

# connect LN nodes
connect alice bob
connect alice alice_loopnode
connect alice_loopnode bob
connect bob charlie
connect bob bob_loopnode
connect bob_loopnode charlie
connect bob_loopnode alice
connect charlie charlie_loopnode
connect charlie_loopnode bob
connect mallory alice
connect mallory bob
connect mallory charlie

ALICE_PUBKEY=\$(pubkey alice)
BOB_PUBKEY=\$(pubkey bob)
CHARLIE_PUBKEY=\$(pubkey charlie)

ALICE_LOOPNODE_PUBKEY=\$(pubkey alice_loopnode)
BOB_LOOPNODE_PUBKEY=\$(pubkey bob_loopnode)
CHARLIE_LOOPNODE_PUBKEY=\$(pubkey charlie_loopnode)

fund alice 1
fund alice 1
fund bob 1
fund bob 1
fund charlie 1
fund alice_loopnode 1
fund bob_loopnode 1
fund bob_loopnode 1
fund charlie_loopnode 1
fund mallory 1
fund mallory 1
fund mallory 1

alice fundchannel id=\${BOB_PUBKEY} amount=100000 push_msat=50000000
alice fundchannel id=\${ALICE_LOOPNODE_PUBKEY} amount=100000 announce=false push_msat=50000000
alice_loopnode fundchannel id=\${BOB_PUBKEY} amount=100000 announce=false push_msat=50000000
bob fundchannel id=\${CHARLIE_PUBKEY} amount=100000 push_msat=50000000
bob fundchannel id=\${BOB_LOOPNODE_PUBKEY} amount=100000 announce=false push_msat=50000000
bob_loopnode fundchannel id=\${CHARLIE_PUBKEY} amount=100000 announce=false push_msat=50000000
bob_loopnode fundchannel id=\${ALICE_PUBKEY} amount=100000 announce=false push_msat=50000000
charlie fundchannel id=\${CHARLIE_LOOPNODE_PUBKEY} amount=100000 announce=false push_msat=50000000
charlie_loopnode fundchannel id=\${BOB_PUBKEY} amount=100000 announce=false push_msat=50000000
mallory fundchannel id=\${ALICE_PUBKEY} amount=150000
mallory fundchannel id=\${BOB_PUBKEY} amount=150000
mallory fundchannel id=\${CHARLIE_PUBKEY} amount=150000

alice setchannelfee \${ALICE_LOOPNODE_PUBKEY} 0 0
alice_loopnode setchannelfee \${ALICE_PUBKEY} 0 0
alice_loopnode setchannelfee \${BOB_PUBKEY} 0 0

charlie setchannelfee \${CHARLIE_LOOPNODE_PUBKEY} 0 0
charlie_loopnode setchannelfee \${CHARLIE_PUBKEY} 0 0
charlie_loopnode setchannelfee \${BOB_PUBKEY} 0 0

bob setchannelfee \${BOB_LOOPNODE_PUBKEY} 0 0
bob_loopnode setchannelfee \${BOB_PUBKEY} 0 0
bob_loopnode setchannelfee \${ALICE_PUBKEY} 0 0
bob_loopnode setchannelfee \${CHARLIE_PUBKEY} 0 0

generate 6
EOF
chmod +x init

# generate init script to initialize dpchannels plugin
cat > init_dpchannels <<EOF
#!/usr/bin/env bash

set -e -o pipefail

alice plugin start /home/simnet/.lightning/customplgn/dpchannels/dpchannels.py
bob plugin start /home/simnet/.lightning/customplgn/dpchannels/dpchannels.py
charlie plugin start /home/simnet/.lightning/customplgn/dpchannels/dpchannels.py

ALICE_LOOPNODE_LISTPEERS=\$(alice_loopnode listchannels)
ALICE_LOOPNODE_LISTPEERS="\${ALICE_LOOPNODE_LISTPEERS::-1},\"pubkey\": \"\$(pubkey alice_loopnode)\"}"
BOB_LOOPNODE_LISTPEERS=\$(bob_loopnode listchannels)
BOB_LOOPNODE_LISTPEERS="\${BOB_LOOPNODE_LISTPEERS::-1},\"pubkey\": \"\$(pubkey bob_loopnode)\"}"
CHARLIE_LOOPNODE_LISTPEERS=\$(charlie_loopnode listchannels)
CHARLIE_LOOPNODE_LISTPEERS="\${CHARLIE_LOOPNODE_LISTPEERS::-1},\"pubkey\": \"\$(pubkey charlie_loopnode)\"}"

alice loopnode "\${ALICE_LOOPNODE_LISTPEERS}"
bob loopnode "\${BOB_LOOPNODE_LISTPEERS}"
charlie loopnode "\${CHARLIE_LOOPNODE_LISTPEERS}"
EOF
chmod +x init_dpchannels
