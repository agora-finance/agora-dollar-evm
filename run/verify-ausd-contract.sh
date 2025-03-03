#!/bin/bash
set -euo pipefail

# Ensure the following environment variables are set before running the script:
source .env
source run/print-highlighted.sh
export FOUNDRY_PROFILE=deploy
export RPC_URL="https://ava-testnet.public.blastapi.io/ext/bc/C/rpc"
# export RPC_URL="https://sepolia-rollup.arbitrum.io/rpc"
# export EXPLORER_API_KEY="PAA4H13U39N9KPY2YES3UXRBUZ6NY84MS9" # ETH
export EXPLORER_API_KEY="DZUJIDPM6NSEXVMD719UHEN3P5YPYV8NX3" # AVAX
# export EXPLORER_API_KEY="DWK15KDFDXVQBYRSV5HWKG76TVFXDHDIBR" # ARB

JSON_FILE="run/contracts.json"

# Loop through each contract entry in the JSON file
jq -c '.[]' "$JSON_FILE" | while read -r row; do
    # Parse the JSON fields
    # CHAIN_ID=$(echo "$row" | jq -r '.chainId')
    NAME=$(echo "$row" | jq -r '.name')
    SRCPATH=$(echo "$row" | jq -r '.srcPath')
    ADDRESS=$(echo "$row" | jq -r '.address')
    CONSTRUCTOR_ARGS=$(echo "$row" | jq -r '.constructorArgs')

    print_highlighted "Verifying contract: $NAME"

    # Execute the forge verify-contract command with the parsed values.
    forge verify-contract "$ADDRESS" "$SRCPATH" \
        --constructor-args "$CONSTRUCTOR_ARGS" \
        --rpc-url "$RPC_URL" \
        -e "$EXPLORER_API_KEY" \
        --compiler-version 0.8.21 \
        --watch
    print_highlighted "Verification successful: $NAME : $ADDRESS"
done
