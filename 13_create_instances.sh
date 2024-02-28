#!/bin/bash

oc rsh openstackclient

openstack image create --min-disk 10 --min-ram 8192 --disk-format qcow2 --container-format bare --file ~/trex.qcow2 --public trex

openstack image create --min-disk 10 --min-ram 8192 --disk-format qcow2 --container-format bare --file ~/testpmd.qcow2 --public testpmd
openstack image list

#Create provider1 network
openstack network create --provider-network-type vlan --provider-physical-network datacentre1 --external provider1 --provider-segment 101

#Create provider2 network
openstack network create --provider-network-type vlan --provider-physical-network datacentre2 --external provider2 --provider-segment 103

openstack network list

#Create subnet for provider
openstack subnet create --subnet-range 172.16.101.0/24 --network provider1  provider1-subnet
openstack subnet create --subnet-range 172.16.102.0/24 --network provider2  provider2-subnet

openstack subnet list

#Create flavor
openstack flavor create  --ram 16392 --disk 20 --vcpus 4 testpmd
openstack flavor set --property  hw:mem_page_size=any --property hw:cpu_policy=dedicated --property hw:emulator_threads_policy=share testpmd

openstack flavor create --ram 16392 --disk 10 --vcpu 8 trex
openstack flavor set --property  hw:mem_page_size=large --property hw:cpu_policy=dedicated --property hw:emulator_threads_policy=share trex


openstack flavor list

openstack compute service list
openstack host list
openstack hypervisor list

openstack keypair create key >key.pem
chmod 600 key.pem

#trex is run on compute-1 and testpmd is run on Compute-0/Computedpdk-0
openstack server create --key key --image testpmd --network provider1 --network provider2 --flavor testpmd vm-testpmd --availability-zone nova:compute-0.localdomain

openstack server create  --key key --image trex --network provider1 --network provider2 --flavor trex vm-trex --availability-zone nova:compute-1.localdomain


openstack server list
openstack server show vm-testpmd
openstack server show vm-trex
