#!/bin/bash

#### Run this as . 08_osp_dataplane_setup_OVN_DPDK.sh to apply the env variables to parent shell

cat <<EOF | oc apply -f -
---
apiVersion: v1
kind: Secret
metadata:
  name: baremetalset-password-secret
  namespace: openstack
type: Opaque
data:
  NodeRootPassword: cmVkaGF0Cg==
EOF

#Environment variables needed for OSP dataplane deployment
export BMH_NAMESPACE=openshift-machine-api
export BMO_PROVISIONING_INTERFACE=enp1s0
export BM_CTLPLANE_INTERFACE=eno2
export BMO_CTLPLANE_INTERFACE=eno2
export BMO_ROOT_PASSWORD_SECRET=baremetalset-password-secret
export EDPM_TOTAL_NODES=1
export DATAPLANE_TOTAL_NODES=1
export DATAPLANE_CHRONY_NTP_SERVER=clock.redhat.com
export DATAPLANE_SSHD_ALLOWED_RANGES="['192.168.122.0/24']"

sh $HOME/install_yamls/devsetup/scripts/gen-ansibleee-ssh-key.sh

#Comment below line in Makefile for 'edpm_deploy_baremetal' task in  $HOME/install_yamls
awk '/\.PHONY: edpm_deploy_baremetal/ {p=1} p && /oc kustomize \${DEPLOY_DIR} \| oc apply -f -/ {print "#", $0; p=0; next} 1' "$HOME/install_yamls/Makefile" > tmpfile && mv tmpfile "$HOME/install_yamls/Makefile"

#Run EDPM dataplane deploy command
make -C $HOME/install_yamls/  edpm_deploy_baremetal


