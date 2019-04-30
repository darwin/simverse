#!/usr/bin/env bash

. cookbook/cookbook.sh

prelude

add bitcoind b1

add lightningd alice
add lightningd bob
add lightningd charlie

# generate init script to build connections
cat > init <<EOF
#!/usr/bin/env bash

set -e -o pipefail

# assuming LN -> Bitcoin connections
#
# alice -> b1 (bitcoind)
# bob -> b1 (bitcoind)
# charlie -> b1 (bitcoind)

# connect LN nodes
connect alice charlie
connect charlie bob
EOF
chmod +x init
