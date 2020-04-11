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


### How to Build
Use the Vagrant file to setup the Vault cluster.  

Time delays are included after the initialisation and unseal operations.

```
$ vagrant validate
$ vagrant status
$ vagrant up
```

Use the Node name to SSH into individual nodes.

```
$ vault ssh vault1
```


