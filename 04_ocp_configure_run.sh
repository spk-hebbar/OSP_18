#!/bin/bash

make -C $HOME/dev-scripts requirements configure && make -C $HOME/dev-scripts/ build_installer ironic install_config ocp_run bell

#If you get an error related to SSH public key, copy them manually to the required file

#If you get an error like a network already exists, then we need to delete the default network.
#make -C $HOME/dev-scripts/ clean
#sudo virsh net-destroy default && sudo virsh net-undefine default
#make -C $HOME/dev-scripts requirements configure

sudo bash -c 'cat > /etc/sysconfig/network-scripts/ifcfg-eno2 << EOF
makefile
DEVICE=eno2
NAME=eno2
TYPE=Ethernet
ONBOOT=yes
BOOTPROTO=none
BRIDGE=OSP_TRUNK
EOF'

sudo ifup eno2

