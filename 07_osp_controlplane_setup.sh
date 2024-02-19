#!/bin/bash


#Run this script as ". 07_osp_controlplane_setup.sh" to apply env to parent shell

export BMH_NAMESPACE=openshift-machine-api
export NNCP_INTERFACE=enp3s0
export NNCP_GATEWAY=192.168.122.1
export NNCP_DNS_SERVER=192.168.122.1
export NETWORK_VLAN_START=111
export NETWORK_VLAN_STEP=1
export NETCONFIG_CR=$HOME/install_yamls/netconfig.yaml
export DNSDATA_CR=$HOME/install_yamls/network_dns_masq.yaml
export DNSMASQ_CR=$HOME/install_yamls/network_dnsdata.yaml
export BMO_SETUP=false
export METALLB_POOL='192.168.122.80-192.168.122.90'
export NNCP_CTLPLANE_IP_ADDRESS_PREFIX=192.168.122
export NNCP_CTLPLANE_IP_ADDRESS_SUFFIX=23

cd $HOME
git clone https://github.com/openstack-k8s-operators/install_yamls.git
#Modify the VLAN ids of gen-nncp.sh, gen-metallb-config.sh
cp -f $HOME/OSP_18/install_yamls_changes/gen* $HOME/install_yamls/scripts/

#OSP Controlplane Network isolation like Controlplane, storage,  internal api & tenant CR’s.
#Need to update files for network isolation with proper subnets and VLAN details based on your cluster and switch configuration
wget -O - https://github.com/openstack-k8s-operators/infra-operator/raw/main/config/samples/network_v1beta1_netconfig.yaml | yq eval '.' - > $HOME/install_yamls/netconfig.yaml
################# UPDATE netconfig.yaml with right VLAN
wget -O - https://github.com/openstack-k8s-operators/infra-operator/raw/main/config/samples/network_v1beta1_dnsdata.yaml | yq eval '.' - > $HOME/install_yamls/network_dnsdata.yaml

wget -O - https://github.com/openstack-k8s-operators/infra-operator/raw/main/config/samples/network_v1beta1_dnsmasq.yaml | yq eval '.' - > $HOME/install_yamls/network_dns_masq.yaml


make -C $HOME/install_yamls/devsetup/ download_tools &&
make -C $HOME/install_yamls/ crc_storage input openstack_wait &&
make -C $HOME/install_yamls/ netconfig_deploy dns_deploy &&
make -C $HOME/install_yamls/ openstack_wait_deploy
cd -

oc patch openstackcontrolplane openstack-galera-network-isolation --type=merge --patch '
spec:
neutron:
  template:
    customServiceConfig: |
    [DEFAULT]
    global_physnet_mtu = 9000
    [ml2]
    mechanism_drivers = ovn
    [ovn]
    vhost_sock_dir = /var/lib/vhost_sockets
    enable_distributed_floating_ip=False
    [ml2_type_vlan]
    network_vlan_ranges = dpdk1:101:104,dpdk2:105:108
ovn:
  template:
   ovnController:
    nicMappings: {"trunk":"enp4s0"}
'
