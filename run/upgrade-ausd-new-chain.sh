#!/bin/bash
set -euo pipefail

# SETUP:
# * Ensure that the Local RPC is running with the vars from the .env file:
#   * correct FIREBLOCKS_CHAIN_ID
#   * correct FORDEFI_ADDRESS (`PROXY_ADMIN_OWNER`)
#   * valid FORDEFI_RPC_URL for the target chain.
#
# * Ensure the following too:
#   * the `PROXY_ADMIN_OWNER` Fordefi account has gas tokens.

# Load environment variables
# source .env
source run/print-highlighted.sh
export FOUNDRY_PROFILE=deploy
export LOCAL_RPC_URL="http://127.0.0.1:8545/owner/aa608dec-bae0-4ee8-b8d0-8b7b7b47a84b"
export PROXY_ADMIN_OWNER="0x99B0E95Fa8F5C3b86e4d78ED715B475cFCcf6E97"

# Set `--prod` for production mode, else testing
if [[ " $@ " == *" --prod "* ]]; then
    PROD_FLAGS="--broadcast --unlocked --slow"
    echo "Production mode: extra flags enabled ($PROD_FLAGS)"
else
    PROD_FLAGS=""
    echo "Testing mode: extra flags disabled"
fi

print_highlighted "Upgrading AUSD Proxy..."
forge script src/script/UpgradeAusd.sol:UpgradeAusd \
 --sender $PROXY_ADMIN_OWNER --rpc-url $LOCAL_RPC_URL $PROD_FLAGS
print_highlighted "AUSD Deployment Done"
