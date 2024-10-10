#!/bin/bash

set -x

##### Run this script from the stack user ######



echo -e "\n$USER ALL=(ALL) NOPASSWD: ALL\n" | sudo tee -a /etc/sudoers           
                                                                                 
#Create a ssh key and ssh copy key using stack user in hypervisor which will be used for OCP nodes.
# Generate SSH key                                                               
ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa -N ""                                 
                                                                                 
# Get the hostname of the hypervisor using command substitution                  
hostname=$(hostname)                                                             
                                                                                 
# Copy the SSH key to the stack user on the hypervisor                           
ssh-copy-id -i ~/.ssh/id_rsa.pub stack@$hostname                                 
                                                                                 
cat > $HOME/.ssh/config << EOF
Host *                                                                           
    StrictHostKeyChecking no                                                     
    UserKnownHostsFile /dev/null                                                 
EOF

#Update internal certificates                                                    
sudo curl -m 120 -k -o /etc/pki/ca-trust/source/anchors/Current-IT-Root-CAs.pem https://certs.corp.redhat.com/certs/Current-IT-Root-CAs.pem
sudo update-ca-trust                                                             
                                                                                 
#Enable rhos-release repo                                                        
sudo dnf install -y https://download.eng.bos.redhat.com/rcm-guest/puddles/OpenStack/rhos-release/rhos-release-latest.noarch.rpm
                                                                                 
#Install required packages                                                       
sudo dnf -y install NetworkManager-initscripts-updown.noarch ipmitool make git-core jq wget dnsmasq

git clone https://github.com/openshift-metal3/dev-scripts.git
 
git clone https://github.com/spk-hebbar/OSP_18.git
