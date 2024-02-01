#!/bin/bash

oc rsh openstackclient

openstack flavor create c1 --vcpus 1 --ram 256 2>/dev/null
openstack flavor list

curl -Lo /tmp/cirros.img http://download.cirros-cloud.net/0.5.2/cirros-0.5.2-x86_64-disk.img
openstack image create --file /tmp/cirros.img cirros --container-format bare --disk-format qcow2 2>/dev/null
openstack image list

openstack network create public --provider-network-type flat --provider-physical-network datacentre --external
openstack subnet create pub_sub --subnet-range 192.168.122.0/24 --allocation-pool start=192.168.122.200,end=192.168.122.210 --gateway 192.168.122.1 --no-dhcp --network public
openstack network list

openstack keypair create key >key.pem
chmod 600 key.pem
openstack network create --provider-network-type geneve dpdk-mgmt
openstack subnet create --subnet-range 70.0.20.0/24 --dhcp --network dpdk-mgmt dpdk-mgmt_subnet

openstack router create router1

openstack router set router1 --external-gateway public
openstack router add subnet router1 dpdk-mgmt_subnet

openstack port create --vnic-type normal --network dpdk-mgmt port1-dpdk
#Port status will be down, once it is attached to server, status becomes up
openstack port list

openstack server create --flavor c1  --nic port-id=port1-dpdk --image cirros --key-name key instance1
openstack server list

openstack floating ip create public --floating-ip-address 192.168.122.200
openstack floating ip list
openstack server add floating ip instance1 192.168.122.200
openstack floating ip list



