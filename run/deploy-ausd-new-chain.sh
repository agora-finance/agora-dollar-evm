#!/bin/bash
set -euo pipefail

# Load environment variables
source .env
source run/print-highlighted.sh
export FOUNDRY_PROFILE=deploy
export LOCAL_RPC_URL="http://127.0.0.1:8545/deployer/aa608dec-bae0-4ee8-b8d0-8b7b7b47a84b"
export AUSD_PROXY_DEPLOYER="0xb53DE4376284C74Ed70Edcb9DaF7256942153FBc"
# export VERIFIER_URL='https://api.routescan.io/v2/network/testnet/evm/43113/etherscan'
# export ETHERSCAN_API_KEY="lgwIK6hptVWZAYKOlaxfUg9IBIYc_lC1"
export OUTPUT_FILE="test_ausd_deployment.txt"

# Set `--prod` for production mode, else testing
if [[ " $@ " == *" --prod "* ]]; then
    PROD_FLAGS="--broadcast --unlocked --slow"
    echo "Production mode: extra flags enabled ($PROD_FLAGS)"
else
    PROD_FLAGS=""
    echo "Testing mode: extra flags disabled"
fi

print_highlighted "Deploying AUSD..."
forge script src/script/DeployAusd.s.sol:DeployAusd \
 --sender $AUSD_PROXY_DEPLOYER --rpc-url $LOCAL_RPC_URL $PROD_FLAGS | tee $OUTPUT_FILE
print_highlighted "AUSD Deployment Done"

print_highlighted "Next Steps \n\t * Find the AUSD Proxy Admin Contract in the Explorer Tx \n\t * Update AgoraConstants on /src/script/AgoraConstants.sol \n\t * Change the LOCAL_RPC_URL to have the PROXY_ADMIN_OWNER as sender address"
