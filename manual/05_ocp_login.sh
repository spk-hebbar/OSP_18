#!/bin/bash
### Always run this as stack user
export KUBECONFIG=/home/stack/dev-scripts/ocp/nfv/auth/kubeconfig

export PASSWORD=$(cat /home/stack/dev-scripts/ocp/nfv/auth/kubeadmin-password)

oc login -u kubeadmin -p ${PASSWORD} https://api.nfv.openstack.lab:6443/

