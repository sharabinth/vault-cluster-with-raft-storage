#!/usr/bin/env bash

echo "Retrieve Unseal key and Root Token from the filesystem"

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
sleep 1s
vault login $VAULT_TOKEN 
sleep 1s
echo "Logged-in as Root"
sleep 15s

echo "Print Vault Status"
sleep 1s

vault status 

echo "Print Raft Status" 
sleep 1s
vault operator raft list-peers
sleep 1s

echo "Vault is unsealed"

# Update the license information if there is a separate license file
LICENSE_FILE=/vagrant/ent/license.txt

if [ -f "$LICENSE_FILE" ]; then 
    echo "Vault License file exists in the ent folder"
    sleep 1s

    LICENSE_KEY=$(cat /vagrant/ent/license.txt)
    vault write sys/license text=$LICENSE_KEY

    echo "Updated the license. License details " 
    sleep 1s
    vault read sys/license
fi

# Add vault root token to the vagrant user profile to avoid logging with the root token 
# Don't do this for the Prod anvironment!
sudo echo "export VAULT_TOKEN=$VAULT_TOKEN" >> /home/vagrant/.bashrc