#!/bin/bash

oc rsh openstackclient
=========================
openstack image create --min-disk 10 --min-ram 8192 --disk-format qcow2 --container-format bare --file ~/testpmd.qcow2 --public image_testpmd

openstack flavor create  --ram 16392 --disk 20 --vcpus 4 flavor_testpmd
openstack flavor set --property  hw:mem_page_size=any --property hw:cpu_policy=dedicated --property hw:emulator_threads_policy=share flavor_testpmd

openstack keypair create key >key.pem
chmod 600 key.pem

#Provider network1
openstack network create --internal --provider-network-type vlan --provider-physical-network data1 --provider-segment xxx --disable-port-security network1
neutron subnet-create network1 6.6.6.0/24 --disable-dhcp --name subnet1
openstack port create --network network1 --vnic-type direct --mac-address f8:f2:1e:03:bf:f4 --binding-profile '{"capabilities": ["switchdev"]}' --no-security-group --disable-port-security vlan1

#Provider network2
openstack network create --internal --provider-network-type vlan --provider-physical-network data2 --provider-segment yyy --disable-port-security network2
neutron subnet-create network2 9.9.9.0/24 --disable-dhcp --name subnet2
openstack port create --network network2 --vnic-type direct --mac-address f8:f2:1e:03:bf:f4 --binding-profile '{"capabilities": ["switchdev"]}' --no-security-group --disable-port-security vlan2

#GENEVE -- tenant network
openstack network create --internal --provider-network-type geneve Geneve
neutron subnet-create Geneve 7.7.7.0/24 --name genevesub
openstack port create --network Geneve --vnic-type direct --mac-address f8:f2:1e:03:bf:f9 --binding-profile '{"capabilities": ["switchdev"]}' geneveport

#External network
openstack network create --external --provider-physical-network external --provider-network-type vlan --provider-segment 101 external
openstack subnet create --gateway 10.10.54.100 --network external --subnet-range 10.10.54.0/24  --dhcp --dns-nameserver 8.8.8.8 --allocation-pool start=10.10.54.101,end=10.10.54.200 external_subnet

openstack router create router1
neutron router-gateway-set router1 external
openstack router add subnet router1 subnet1
openstack router add subnet router1 subnet2
openstack router add subnet router1 genevesub

openstack port list

#Update port-id of vlan1, vlan2, geneveport
openstack server create --flavor flavor_testpmd --image image_testpmd --nic port-id=d4c75bcd-b0ab-4cb4-9683-729c83e2a564 --nic port-id=d4c75bcd-b0ab-4cb4-9683-729c83e2a564 --nic port-id=d4c75bcd-b0ab-4cb4-9683-729c83e2a564 --key-name key --availability-zone nova:computesriov-0.localdomain vm_testpmd


openstack flavor list
openstack compute service list
openstack host list
openstack hypervisor list
openstack server list
openstack server show vm_testpmd
