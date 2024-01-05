#!/bin/bash
### Always run this as stack user
export KUBECONFIG=/home/stack/dev-scripts/ocp/rhospnfv/auth/kubeconfig

export PASSWORD=$(cat /home/stack/dev-scripts/ocp/rhospnfv/auth/kubeadmin-password)

oc login -u kubeadmin -p ${PASSWORD} https://api.rhospnfv.openstack.lab:6443/

