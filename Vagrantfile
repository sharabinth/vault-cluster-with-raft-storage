# -*- mode: ruby -*-
# vi: set ft=ruby :

### Define environment variables to pass on to provisioner

# Define Vault Primary HA server details
VAULT_HA_SERVER_IP_PREFIX = ENV['VAULT_HA_SERVER_IP_PREFIX'] || "10.100.1.1"
RAFT_NODE_1_IP = ENV['RAFT_NODE_1_IP'] || "10.100.1.11"
RAFT_NODE_2_IP = ENV['RAFT_NODE_2_IP'] || "10.100.1.12"
RAFT_NODE_3_IP = ENV['RAFT_NODE_3_IP'] || "10.100.1.13"

# Enabled for license autoloading feature from Vault 1.8+.  
# If the value is not set to YES then the generated Vault config file will not set for auto loading 
# of the license
LICENSE_AUTO_LOAD = "YES"

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu-18.04.04-with-docker-ce-0.1.box"
  
  # set up the Vault Cluster.  
  # To create multi-node cluster change it to 1..3
  (1..1).each do |i|
    config.vm.define "vault#{i}" do |v1|
      v1.vm.hostname = "v#{i}"
      
      v1.vm.network "private_network", ip: VAULT_HA_SERVER_IP_PREFIX+"#{i}"

      v1.vm.provision "shell", 
                      path: "scripts/setupVaultServer.sh",
                      env: {'RAFT_NODE' => "Node#{i}", 
                            'RAFT_NODE_1_IP' => RAFT_NODE_1_IP,
                            'RAFT_NODE_2_IP' => RAFT_NODE_2_IP,
                            'RAFT_NODE_3_IP' => RAFT_NODE_3_IP,
                            'LICENSE_AUTO_LOAD' => LICENSE_AUTO_LOAD
                          }

      if i == 1 then
        v1.vm.provision "shell", 
                      path: "scripts/initAndUnsealVault.sh",
                      env: {'LICENSE_AUTO_LOAD' => LICENSE_AUTO_LOAD}
      end

      if i > 1 then
        v1.vm.provision "shell", 
                      path: "scripts/unsealVault.sh",
                      env: {'LICENSE_AUTO_LOAD' => LICENSE_AUTO_LOAD}
      end
    end
  end
  
end
