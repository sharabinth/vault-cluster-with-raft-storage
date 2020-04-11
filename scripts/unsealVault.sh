#!/usr/bin/env bash

echo "Retrieve Unseal key and Roott Token from the filesystem"
# UNSEAL_KEY=$(cat /vagrant/primary-keys.txt | jq -r .unseal_keys_b64[0])
# VAULT_TOKEN=$(echo /vagrant/primary-keys.txt | jq -r .root_token)

UNSEAL_KEY=$(cat /vagrant/primary-unseal-key.txt)
VAULT_TOKEN=$(cat /vagrant/primary-root-token.txt)

echo "Print Unseal Key"
echo $UNSEAL_KEY

echo "Print Root Token"
echo $VAULT_TOKEN

echo "Unseal Vault Started"
vault operator unseal $UNSEAL_KEY
echo "Unseal Vault Completed"
sleep 15s

echo "Print Vault Status"
vault status
sleep 5s
echo "Check for availability of Performance Standby Node"

echo "Login with Root Token"
vault login $VAULT_TOKEN 
echo "Logged-in as Root"
sleep 15s

echo "Print Vault Status"
vault status 

echo "Print Raft Status"
vault operator raft list-peers

echo "Vault is unsealed"

# Update the license information if there is a separate license file
LICENSE_FILE=/vagrant/ent/license.txt

if [ -f "$LICENSE_FILE" ]; then 
    echo "Vault License file exists in the ent folder"

    LICENSE_KEY=$(cat /vagrant/ent/license.txt)
    vault write sys/license text=$LICENSE_KEY

    echo "Updated the license. License details "
    vault read sys/license
fi