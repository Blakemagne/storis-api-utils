#!/bin/bash

# API endpoint and credentials
AUTH_URL="https://api.storis.com/api/authenticate"
USERNAME="[email address]"
PASSWORD="[secret key]"

# Call the authentication API to get a new token
RESPONSE=$(curl -s -X POST "$AUTH_URL" \
-H "Content-Type: application/json" \
--user "$USERNAME:$PASSWORD")

# Extract the access token from the response
NEW_TOKEN=$(echo "$RESPONSE" | jq -r '.token.access_token')

# Check if the token was successfully retrieved
if [ -z "$NEW_TOKEN" ] || [ "$NEW_TOKEN" == "null" ]; then
    echo "Error: Failed to fetch new token. Response: $RESPONSE"
    exit 1
fi

# Update the ~/.my_env_variables file
echo "export BEARER_TOKEN=\"Bearer $NEW_TOKEN\"" > ~/.my_env_variables

# Secure the file
chmod 600 ~/.my_env_variables

# Reload the environment variables
source ~/.my_env_variables

echo "Token refreshed and updated successfully."
