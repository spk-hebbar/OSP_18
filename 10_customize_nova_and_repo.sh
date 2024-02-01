cat > custom-nova-dpdk.yaml<<EOL
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: cpu-pinning-nova
data:
  04-cpu-pinning-nova.conf: |

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
    - cpu-pinning-nova
  secrets:
    - nova-cell1-compute-config
    - nova-migration-ssh-key
  playbook: osp.edpm.nova
EOL

oc apply -f custom-nova-dpdk.yaml

cat >repo-setup.yaml<<EOL
---
apiVersion: dataplane.openstack.org/v1beta1
kind: OpenStackDataPlaneService
metadata:
  labels:
    app.kubernetes.io/name: openstackdataplaneservice
    app.kubernetes.io/instance: openstackdataplaneservice-repo-setup
    app.kubernetes.io/part-of: dataplane-operator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/created-by: install_yamls
  name: repo-setup
spec:
  label: repo-setup
  play: |
    - hosts: all
      strategy: linear
      tasks:
        - name: Enable podified-repos
          become: true
          ansible.builtin.shell: |
            set -euxo pipefail
            pushd /var/tmp
            curl -sL https://github.com/openstack-k8s-operators/repo-setup/archive/refs/heads/main.tar.gz | tar -xz
            pushd repo-setup-main
            python3 -m venv ./venv
            PBR_VERSION=0.0.0 ./venv/bin/pip install ./
            # This is required for FIPS enabled until trunk.rdoproject.org
            # is not being served from a centos7 host, tracked by
            # https://issues.redhat.com/browse/RHOSZUUL-1517
            update-crypto-policies --set FIPS:NO-ENFORCE-EMS
            ./venv/bin/repo-setup current-podified -b antelope
            popd
            rm -rf repo-setup-main
EOL

oc create -f repo-setup.yaml

