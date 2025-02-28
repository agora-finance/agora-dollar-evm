#!/bin/bash
set -euo pipefail

# Load environment variables
# source .env
export FOUNDRY_PROFILE=deploy
export LOCAL_RPC_URL="http://127.0.0.1:8545/aa608dec-bae0-4ee8-b8d0-8b7b7b47a84b"
export AUSD_PROXY_DEPLOYER="0xb53DE4376284C74Ed70Edcb9DaF7256942153FBc"

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
  echo -e "$message"
  echo "$border"
}

print_highlighted "Deploying AUSD..."
forge script src/script/DeployAusd.s.sol:DeployAusd \
 --sender $AUSD_PROXY_DEPLOYER --rpc-url $LOCAL_RPC_URL $PROD_FLAGS
print_highlighted "AUSD Deployment Done"

print_highlighted "Next Steps \n\t * Find the AUSD Proxy Admin Contract in the Explorer Tx \n\t * Update AgoraConstants on /src/script/AgoraConstants.sol \n\t * Change the LOCAL_RPC_URL to have the PROXY_ADMIN_OWNER as sender address"
