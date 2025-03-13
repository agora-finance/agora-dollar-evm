#!/bin/bash
set -euo pipefail

# Ensure the following environment variables are set before running the script:
source ../.env # loading the .env file from the root directory
source run/print-highlighted.sh
export FOUNDRY_PROFILE=deploy

JSON_FILE="run/contracts.json"

if [[ " $@ " == *" --etherscan "* ]]; then
    if [[ -z "${EXPLORER_API_KEY}" ]]; then f
        echo "Error: EXPLORER_API_KEY is required and not set"
        exit 1
    fi
    EXPLORER_FLAGS="-e $EXPLORER_API_KEY"
elif [[ " $@ " == *" --blockscout "* ]]; then
    if [[ -z "${VERIFIER_URL}" ]]; then
        echo "Error: VERIFIER_URL is required and not set"
        exit 1
    fi
    EXPLORER_FLAGS="--verifier blockscout --verifier-url '$VERIFIER_URL'"
else
    echo "Error: Explorer flag missing (use --etherscan or --blockscout)"
    exit 1
fi

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
        $EXPLORER_FLAGS \
        --compiler-version 0.8.21 \
        --watch
    print_highlighted "Verification successful: $NAME : $ADDRESS"
done
