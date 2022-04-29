#!/usr/bin/env bash

export PATH=$PATH:/usr/local/bin

echo "Installing Vault enterprise version ..."
cp /vagrant/ent/vault*.zip ./vault.zip
#cp /vagrant/ent/vault-enterprise_*.zip ./vault.zip
#cp /vagrant/ent/vault ./vault

unzip vault.zip
chown root:root vault
chmod 0755 vault
mv vault /usr/local/bin
rm -f vault.zip

echo "Creating Vault service account ..."
useradd -r -d /etc/vault -s /bin/false vault

echo "Creating directory structure ..."
mkdir -p /etc/vault/pki
mkdir -p /etc/vault/raft
chown -R root:vault /etc/vault
#chmod -R 0750 /etc/vault
chmod -R 0770 /etc/vault

mkdir /var/{lib,log}/vault
chown vault:vault /var/{lib,log}/vault
chmod 0750 /var/{lib,log}/vault

echo "Creating Vault configuration ..."
echo 'export VAULT_ADDR="http://localhost:8200"' | tee /etc/profile.d/vault.sh


NETWORK_INTERFACE=$(ls -1 /sys/class/net | grep -v lo | sort -r | head -n 1)
IP_ADDRESS=$(ip address show $NETWORK_INTERFACE | awk '{print $2}' | egrep -o '([0-9]+\.){3}[0-9]+')
HOSTNAME=$(hostname -s)

tee /etc/vault/vault.hcl << EOF
api_addr = "http://${IP_ADDRESS}:8200"
cluster_addr = "https://${IP_ADDRESS}:8201"
ui = true

storage "raft" {
  path    = "/etc/vault/raft/"
  node_id = "${RAFT_NODE}"

  retry_join {
    leader_api_addr = "http://${RAFT_NODE_1_IP}:8200"
  }
  retry_join {
    leader_api_addr = "http://${RAFT_NODE_2_IP}:8200"
  }
  retry_join {
    leader_api_addr = "http://${RAFT_NODE_3_IP}:8200"
  }
}

listener "tcp" {
  address       = "0.0.0.0:8200"
  cluster_addr  = "${IP_ADDRESS}:8201"
  tls_disable   = "true"
}

#license_path = "/etc/vault/license.txt"
EOF


# If license autoloading is set then set the path to the license file
if [ ${LICENSE_AUTO_LOAD} == "YES" ]; then 
    echo "Vault License Auto Loading is Enabled. Make sure the Vault binary version is 1.8+"
    echo "Setting the license_path in the Vault config file"

    echo 'license_path = "/etc/vault/license.txt"' | tee -a /etc/vault/vault.hcl
    cp /vagrant/ent/license.txt /etc/vault/
fi


chown root:vault /etc/vault/vault.hcl
chmod 0640 /etc/vault/vault.hcl

chown root:vault /etc/vault/license.txt
chmod 0640 /etc/vault/license.txt

tee /etc/systemd/system/vault.service << EOF
[Unit]
Description="Vault secret management tool"
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/vault/vault.hcl

[Service]
User=vault
Group=vault
PIDFile=/var/run/vault/vault.pid
ExecStart=/usr/local/bin/vault server -config=/etc/vault/vault.hcl
StandardOutput=file:/var/log/vault/vault.log
StandardError=file:/var/log/vault/vault.log
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
KillSignal=SIGINT
Restart=on-failure
RestartSec=42
TimeoutStopSec=30
StartLimitInterval=60
StartLimitBurst=3
LimitMEMLOCK=infinity

[Install]
WantedBy=multi-user.target
EOF


systemctl daemon-reload
systemctl enable vault
systemctl restart vault
