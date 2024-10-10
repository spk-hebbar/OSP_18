#!/bin/bash

git clone https://github.com/openstack-k8s-operators/dataplane-operator.git
oc apply -f dataplane-operator/config/services/

