# GET Product Details Tool (with auto auth)
This setup automates the process of refreshing a Bearer token and querying product details using the Storis API.

## Overview

- **`refresh_token.sh`**: Automatically fetches a new Bearer token and updates it in a secure environment file.
- **`GET_product_details.sh`**: Retrieves product details by calling the API with the refreshed Bearer token.

---

## Setup Instructions

### 1. Install Dependencies

Ensure the system has the following dependencies installed:

- **cURL**: For making HTTP requests.
  ```bash
  sudo apt install curl        # Ubuntu/Debian
  brew install curl            # macOS
  ```
- **jq**: For parsing JSON responses.
  ```bash
  sudo apt install jq          # Ubuntu/Debian
  brew install jq              # macOS
  ```

---

### 2. Clone or Create the Scripts

#### 2.1. Create the `refresh_token.sh` Script

1. Create the script:
   ```bash
   nano refresh_token.sh
   ```

2. Add the following code:

   ```bash
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
   ```

3. Save and exit (`CTRL + O`, then `CTRL + X`).

---

#### 2.2. Create the `GET_product_details.sh` Script

1. Create the script:
   ```bash
   nano GET_product_details.sh
   ```

2. Add the following code:

   ```bash
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
   ```

3. Save and exit (`CTRL + O`, then `CTRL + X`).

---

### 3. Make the Scripts Executable

Run the following commands to make the scripts executable:

```bash
chmod +x refresh_token.sh
chmod +x GET_product_details.sh
```

---

### 4. Run the Scripts

#### 4.1. Refresh the Token

Run the `refresh_token.sh` script to fetch the Bearer token:

```bash
./refresh_token.sh
```

This will save the token to the `~/.my_env_variables` file.

#### 4.2. Get Product Details

Run the `GET_product_details.sh` script to query product details. Replace `<ProductId>` with the desired product ID:

```bash
./GET_product_details.sh <ProductId>
```

Example:

```bash
./GET_product_details.sh 2590315
```

---

### 5. Automate Token Refresh with Cron

1. Open the cron editor:
   ```bash
   crontab -e
   ```

2. Add a cron job to refresh the token every 12 hours (or another interval as needed):

   ```bash
   0 */12 * * * /path/to/refresh_token.sh
   ```

This ensures the Bearer token is always refreshed before expiration.

---

## Troubleshooting

1. **Error: Missing Dependencies**
   - Ensure `curl` and `jq` are installed. Reinstall if necessary.

2. **Error: Token Not Refreshed**
   - Verify the username and password in the `refresh_token.sh` script.

3. **Error: Product Details Not Retrieved**
   - Ensure the Bearer token is valid.
   - Verify the `ProductId` exists in the system.

---

## File Structure Example

```
/path/to/scripts/
├── refresh_token.sh
├── GET_product_details.sh
└── ~/.my_env_variables
```

---

## Security Notes

1. **Protect Credentials**:
   - Store the `refresh_token.sh` script and the `~/.my_env_variables` file securely.
   - Use `chmod 600` to restrict access.

2. **Rotate Passwords**:
   - Regularly update the password used in the `refresh_token.sh` script to minimize security risks.

