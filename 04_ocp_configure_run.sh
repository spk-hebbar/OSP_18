#!/bin/bash

make -C $HOME/dev-scripts requirements configure && make -C $HOME/dev-scripts/ build_installer ironic install_config ocp_run bell

#If you get an error related to SSH public key, copy them manually to the required file

#If you get an error like a network already exists, then we need to delete the default network.
#make -C $HOME/dev-scripts/ clean
#sudo virsh net-destroy default && sudo virsh net-undefine default
#make -C $HOME/dev-scripts requirements configure

sudo ip link add link eno4 name eno4.118 type vlan id 118


echo -e "DEVICE=external\nTYPE=Bridge\nONBOOT=yes\nBOOTPROTO=static\nZONE=libvirt" | sudo dd of=/etc/sysconfig/network-scripts/ifcfg-external
cat > /home/stack/external.xml << EOF
<network>
   <name>external</name>
   <forward mode='bridge'/>
   <bridge name='external'/>
</network>
EOF
sudo ifdown external
sudo ifup external
sudo virsh net-define /home/stack/external.xml
sudo virsh net-start external
sudo virsh net-autostart external

sudo bash -c 'cat > /etc/sysconfig/network-scripts/ifcfg-eno1 << EOF
makefile
DEVICE=eno1
NAME=eno1
TYPE=Ethernet
ONBOOT=yes
BRIDGE=external
EOF'

sudo ifup eno1

sudo bash -c 'cat > /etc/sysconfig/network-scripts/ifcfg-eno4.118 << EOF
makefile                                                                         
DEVICE=eno4.118                                                                  
NAME=eno4.118@eno4                                                               
TYPE=Vlan                                                                                                                                                                                                                                     
ONBOOT=yes                                                                       
BRIDGE=rhospnfvbm 
EOF'

sudo ifup eno4.118

sudo bash -c 'cat > /etc/sysconfig/network-scripts/ifcfg-eno2 << EOF
makefile                                                                         
DEVICE=eno2                                                                 
NAME=eno2                                                           
TYPE=Ethernet 
ONBOOT=yes                                                                       
BRIDGE=OSP_TRUNK
EOF'

sudo ifup eno2

