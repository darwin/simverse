#!/usr/bin/env bash

. cookbook/cookbook.sh

prelude

add bitcoind
add lnd alice

add bitcoind
add lnd bob
add lnd charlie

# generate init script to build connections
cat > init <<EOF
#!/usr/bin/env bash

set -e -o pipefail

# connect bitcoin nodes
connect b1 b2

# connect LN nodes
connect alice charlie
connect charlie bob
EOF
chmod +x init

cat > fund_all <<EOF
#!/usr/bin/env bash

set -e -o pipefail

fund alice 10
fund charlie 5
EOF
chmod +x fund_all

cat > open_channels <<EOF
#!/usr/bin/env bash

set -e -o pipefail

open_channel alice charlie 0.1
open_channel charlie bob 0.1
EOF
chmod +x open_channels
