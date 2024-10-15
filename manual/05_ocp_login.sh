#!/bin/bash
### Always run this as stack user
export KUBECONFIG=/home/stack/src/dev-scripts/ocp/ocp/auth/kubeconfig

export PASSWORD=$(cat /home/stack/src/dev-scripts/ocp/ocp/auth/kubeadmin-password)

oc login -u kubeadmin -p ${PASSWORD} https://api.ocp.openstack.lab:6443/

