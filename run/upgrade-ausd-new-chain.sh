#!/bin/bash
set -euo pipefail

# Load environment variables
# source .env
export FOUNDRY_PROFILE=deploy
export LOCAL_RPC_URL="http://127.0.0.1:8545/aa608dec-bae0-4ee8-b8d0-8b7b7b47a84b"
export PROXY_ADMIN_OWNER="0x99B0E95Fa8F5C3b86e4d78ED715B475cFCcf6E97"

# Set this to true for production mode, false for testing
PROD=false

if [ "$PROD" = true ]; then
    PROD_FLAGS="--broadcast --unlocked --slow"
    echo "Production mode: extra flags enabled ($PROD_FLAGS)"
else
    PROD_FLAGS=""
    echo "Testing mode: extra flags disabled"
fi

print_highlighted() {
  local message="$1"
  local border="~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  echo "$border"
  echo "$message"
  echo "$border"
}

print_highlighted "Upgrading AUSD Proxy..."
forge script src/script/UpgradeAusd.sol:UpgradeAusd \
 --sender $PROXY_ADMIN_OWNER --rpc-url $LOCAL_RPC_URL $PROD_FLAGS
print_highlighted "AUSD Deployment Done"
