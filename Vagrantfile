# -*- mode: ruby -*-
# vi: set ft=ruby :

### Define environment variables to pass on to provisioner

# Define Vault Primary HA server details
VAULT_HA_SERVER_IP_PREFIX = ENV['VAULT_HA_SERVER_IP_PREFIX'] || "10.100.1.1"
RAFT_NODE_1_IP = ENV['RAFT_NODE_1_IP'] || "10.100.1.11"
RAFT_NODE_2_IP = ENV['RAFT_NODE_2_IP'] || "10.100.1.12"
RAFT_NODE_3_IP = ENV['RAFT_NODE_3_IP'] || "10.100.1.13"

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu-18.04.04-with-docker-ce-0.1.box"
  
  # set up the Active Vault Node
  (1..1).each do |i|
    config.vm.define "vault#{i}" do |v1|
      v1.vm.hostname = "v#{i}"
      
      v1.vm.network "private_network", ip: VAULT_HA_SERVER_IP_PREFIX+"#{i}"

      v1.vm.provision "shell", 
                      path: "scripts/setupVaultServer.sh",
                      env: {'RAFT_NODE' => 'Node1', 
                            'RAFT_NODE_1_IP' => RAFT_NODE_1_IP,
                            'RAFT_NODE_2_IP' => RAFT_NODE_2_IP,
                            'RAFT_NODE_3_IP' => RAFT_NODE_3_IP}

      v1.vm.provision "shell", 
                      path: "scripts/initAndUnsealVault.sh"
    end
  end

  # set up the Standby Vault Nodes
  # Since VM 1 is used for the Active node, for the standby loop start the number from 2 instead of 1
  # as this is used in naming the VMs.
  (2..2).each do |i|
    config.vm.define "vault#{i}" do |v1|
      v1.vm.hostname = "v#{i}"
      
      v1.vm.network "private_network", ip: VAULT_HA_SERVER_IP_PREFIX+"#{i}"

      v1.vm.provision "shell", 
                      path: "scripts/setupVaultServer.sh",
                      env: {'RAFT_NODE' => "Node#{i}", 
                            'RAFT_NODE_1_IP' => RAFT_NODE_1_IP,
                            'RAFT_NODE_2_IP' => RAFT_NODE_2_IP,
                            'RAFT_NODE_3_IP' => RAFT_NODE_3_IP}

      v1.vm.provision "shell", 
                      path: "scripts/unsealVault.sh"
    end
  end

end
