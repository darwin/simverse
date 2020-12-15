#!/usr/bin/env bash

. cookbook/cookbook.sh

prelude

add bitcoind



add lightningd alice
# cp -r "$SIMVERSE_REPOS/plugins/jitrebalance" "$SIMVERSE_WORKSPACE/$SIMNET_NAME/_volumes/lightning-data-alice/plugins"

LIGHTNINGD_EXTRA_PARAMS='--plugin=/home/simnet/.lightning/plugins/jitrebalance.py'
add lightningd bob
cp -r "$SIMVERSE_REPOS/plugins/jitrebalance" "$SIMVERSE_WORKSPACE/$SIMNET_NAME/_volumes/lightning-data-bob/plugins"
LIGHTNINGD_EXTRA_PARAMS=''

add lightningd charlie
# cp -r "$SIMVERSE_REPOS/plugins/jitrebalance" "$SIMVERSE_WORKSPACE/$SIMNET_NAME/_volumes/lightning-data-charlie/plugins"


# generate init script to build connections
cat > init <<EOF
#!/usr/bin/env bash

set -e -o pipefail

# connect LN nodes
connect alice bob
connect bob charlie
fund alice 10
fund bob 10
open_channel alice bob 0.1
open_channel bob charlie 0.1
EOF
chmod +x init
