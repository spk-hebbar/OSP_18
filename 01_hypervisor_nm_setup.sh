#!/bin/bash

### Run this as root user
# Enable command execution logging
set -x


echo 'net.ipv4.ip_forward = 1' | tee /etc/sysctl.d/98-ip_forward.conf

sysctl -p /etc/sysctl.d/98-ip_forward.conf

cat > /etc/NetworkManager/conf.d/00-use-dnsmasq.conf << EOF_CAT

[main]
dns = dnsmasq
EOF_CAT


echo 'addn-hosts=/etc/hosts' > /etc/NetworkManager/dnsmasq.d/98-local-hosts.conf

cat > /etc/NetworkManager/dnsmasq.d/99-forwarders.conf << EOF_DNS
server=10.47.242.10
server=10.38.5.26
EOF_DNS



#  Based on compute node static controlplane ip
cat > /etc/NetworkManager/dnsmasq.d/01-compute.conf << EOF
address=/nfv02/192.168.122.100
EOF
