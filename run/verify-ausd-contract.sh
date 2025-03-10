#!/bin/bash
set -euo pipefail

# Ensure the following environment variables are set before running the script:
source .env
source run/print-highlighted.sh
export FOUNDRY_PROFILE=deploy
# export RPC_URL="https://testnet-rpc2.monad.xyz/52227f026fa8fac9e2014c58fbf5643369b3bfc6"
# export EXPLORER_API_KEY="PAA4H13U39N9KPY2YES3UXRBUZ6NY84MS9" # ETH
# export RPC_URL="https://ava-testnet.public.blastapi.io/ext/bc/C/rpc"
# export EXPLORER_API_KEY="DZUJIDPM6NSEXVMD719UHEN3P5YPYV8NX3" # AVAX
# export RPC_URL="https://sepolia-rollup.arbitrum.io/rpc"
# export EXPLORER_API_KEY="DWK15KDFDXVQBYRSV5HWKG76TVFXDHDIBR" # ARB
# export RPC_URL="https://rpc-amoy.polygon.technology/"
# export EXPLORER_API_KEY="XFFIN7ITQGYEN74PU8RQSPARKGBHB8E8N7" # POS
# export RPC_URL="https://optimism-sepolia.drpc.org"
# export EXPLORER_API_KEY="I124XHV49G1JWY4ABNQBIHW4WX13S6Z33S" # OP
# export RPC_URL="https://sepolia.base.org"
# export EXPLORER_API_KEY="N9SVE6ZWKBAKZUN56NZ9WVQB6Q4S4YTN62"

JSON_FILE="run/contracts.json"

# Loop through each contract entry in the JSON file
jq -c '.[]' "$JSON_FILE" | while read -r row; do
    # Parse the JSON fields
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
