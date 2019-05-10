#!/usr/bin/env bash

. cookbook/cookbook.sh

prelude

add bitcoind

add eclair alice
add eclair bob
add eclair charlie

# generate init script to build connections
cat > init <<EOF
#!/usr/bin/env bash

set -e -o pipefail

# connect LN nodes
connect alice charlie
connect charlie bob
EOF
chmod +x init
