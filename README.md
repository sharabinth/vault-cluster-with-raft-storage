### Vault Cluster Setup With Integrated Storage

Vault Cluster Setup with Integrated Raft Storage.  

By default this will setup a 3 Node Vault Cluster.  But the numbers can be changed by altering the Vagrant file.

Vault cluster is initialised and all Vault Nodes are unsealed.

Raft peers are automatically joined to form the Raft cluster.

## Pre Requisites

# Ubuntu 18.04.04 Image With Required Utils
The ```Vagrantfile``` uses a special Ubuntu 18.04.04 image with Docker and few other utils included in the image.

This image can be created using ```packer```.  

The packer template is located at https://github.com/sharabinth/packer-ubuntu-18.04.04 

If the base Ubuntu image is used then please make sure to install ```jq``` and ```unzip``` into the image as these two are required to execute the scripts.

# Vault Binary with 1.4 or later
This repo uses the Integrated Storage as the storage backend for Vault.  This is supported from Vault 1.4+

Create a folder named as ```ent``` and copy the Vault Enterprise binary into the ```ent``` folder.  Vault Open Source binary can also be used.  

# Vault License File
If you have a separate license file then create a file named as ```license.txt``` and copy the license information into it.  Place the file in the ```ent``` folder.  Vault ADP Module requires an additional special license which is not part of Vault Enterprise.

If the license file exists then it will be used to update the existing Vault license.


## How to Build
Use the Vagrant file to setup the Vault cluster.  

Time delays are included after the initialisation and unseal operations.

```
$ vagrant validate
$ vagrant status
$ vagrant up
```

The output of the initialisation process is saved in the file ```primary-keys.txt```.
The extract of the unseal key is saved in the file ```primary-unseal-key.txt```
The initial root token is saved in the file ```primary-root-token.txt```

Use the Node name to SSH into individual nodes.

```
$ vault ssh vault1
```


## How to Test

SSH into Vault 1

```

$ vagrant ssh vault1

vagrant@v1:~$ vault status
Key             Value
---             -----
Seal Type       shamir
Initialized     true
Sealed          false
Total Shares    1
Threshold       1
Version         1.4.0+prem
Cluster Name    vault-cluster-32f251fc
Cluster ID      6a4987ba-e8d5-00ea-27e8-df8dfbe464a4
HA Enabled      true
HA Cluster      https://10.100.1.11:8201
HA Mode         active
Last WAL        20

vagrant@v1:~$ cat /vagrant/primary-root-token.txt
s.jHz7FhWrHDAbzdAbPvek3kAT

vagrant@v1:~$ vault login s.jHz7FhWrHDAbzdAbPvek3kAT
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                  Value
---                  -----
token                s.jHz7FhWrHDAbzdAbPvek3kAT
token_accessor       wpjs0FpFpEC2zJyi2UiZ6iFP
token_duration       ∞
token_renewable      false
token_policies       ["root"]
identity_policies    []
policies             ["root"]


vagrant@v1:~$ vault operator raft list-peers
Node     Address             State       Voter
----     -------             -----       -----
Node1    10.100.1.11:8201    leader      true
Node2    10.100.1.12:8201    follower    true
Node3    10.100.1.13:8201    follower    true

```

Similar commands can be executed in the other nodes as well.

