#!/bin/bash

# Ensure the environment variable file is sourced
if [ -f ~/.my_env_variables ]; then
    source ~/.my_env_variables
else
    echo "Error: Environment file (~/.my_env_variables) not found. Please run the refresh_token.sh script to generate it."
    exit 1
fi

# Check if the Bearer token is set
if [ -z "$BEARER_TOKEN" ]; then
    echo "Error: BEARER_TOKEN is not set. Please refresh the token using the refresh_token.sh script."
    exit 1
fi

# Ensure the ProductId argument is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: ./GET_product_details.sh <ProductId>"
    exit 1
fi

# Extract the ProductId argument
PRODUCT_ID=$1

# API URL
API_URL="https://api.storis.com/api/Products/Detail?ProductIds=${PRODUCT_ID}&="

# Make the API call
curl -X GET "$API_URL" \
-H "Content-Type: application/json" \
-H "Authorization: $BEARER_TOKEN" \
| jq
