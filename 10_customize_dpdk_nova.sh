cat > custom-nova-dpdk.yaml<<EOL
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: cpu-pinning-nova-dpdk
data:
  25-cpu-pinning-nova.conf: |

    [DEFAULT]
    reserved_host_memory_mb = 4096
    [compute]
    cpu_shared_set = 0-3,24-27
    cpu_dedicated_set = 8-23,32-47
---
apiVersion: dataplane.openstack.org/v1beta1
kind: OpenStackDataPlaneService
metadata:
  name: nova-custom-ovsdpdk
spec:
  label: nova-custom-ovsdpdk
  configMaps:
    - cpu-pinning-nova-dpdk
  secrets:
    - nova-cell1-compute-config
    - nova-migration-ssh-key
  playbook: osp.edpm.nova
EOL

oc apply -f custom-nova-dpdk.yaml


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
        network_vlan_ranges = dpdk1:xxx:xxx,dpdk2:yyy:yyy,external:101:101
        [neutron]
        physnets = dpdk1, dpdk2
        [neutron_physnet_dpdk1]
        numa_nodes = 0
        [neutron_physnet_dpdk2]
        numa_nodes = 0
        [neutron_tunnel]
        numa_nodes = 0

  ovn:
    template:
      ovnController:
        nicMappings: {"external":"enp4s0"}
'
