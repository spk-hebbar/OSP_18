
cat > custom-nova-sriov.yaml<<EOL

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: cpu-pinning-nova-sriov
data:
  25-cpu-pinning-nova.conf: |

    [DEFAULT]
    reserved_host_memory_mb = 4096
    [compute]
    cpu_shared_set = 0-3,24-27
    cpu_dedicated_set = 8-23,32-47
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: sriov-nova
data:
  03-sriov-nova.conf: |

    [libvirt]
    cpu_power_management=false

    [pci]
    passthrough_whitelist = { "devname":"enp4s0f0np0", "physical_network":"sriov1", "trusted":"true" }
    passthrough_whitelist = { "devname":"enp4s0f1np1", "physical_network":"sriov2", "trusted":"true" }
---
apiVersion: dataplane.openstack.org/v1beta1
kind: OpenStackDataPlaneService
metadata:
  name: nova-custom-sriov
spec:
  label: dataplane-deployment-nova-custom-sriov
  configMaps:
    - cpu-pinning-nova-sriov
    - sriov-nova
  secrets:
    - nova-cell1-compute-config
    - nova-migration-ssh-key
  playbook: osp.edpm.nova
EOL
oc apply -f custom-nova-sriov.yaml


oc patch openstackcontrolplane openstack-galera-network-isolation --type=merge --patch '
spec:
  neutron:
    template:
      customServiceConfig: |
        [DEFAULT]
        global_physnet_mtu = 9000
        [ml2]
        mechanism_drivers = ovn,sriovnicswitch
        [ovn]
        vhost_sock_dir = /var/lib/vhost_sockets
        enable_distributed_floating_ip=False
        [ml2_type_vlan]
        network_vlan_ranges = sriov1:xxx:xxx,sriov2:yyy:yyy,external:101:101
  ovn:
    template:
      ovnController:
        nicMappings: {"external":"enp4s0"}
'

oc patch openstackcontrolplane openstack-galera-network-isolation  -n openstack --type=merge --patch '
spec:
  nova:
    template:
      schedulerServiceTemplate:
        customServiceConfig: |
          [filter_scheduler]
          enabled_filters = AvailabilityZoneFilter, ComputeFilter, ComputeCapabilitiesFilter, ImagePropertiesFilter, ServerGroupAntiAffinityFilter, ServerGroupAffinityFilter, PciPassthroughFilter, AggregateInstanceExtraSpecsFilter
          available_filters = nova.scheduler.filters.all_filters
'
