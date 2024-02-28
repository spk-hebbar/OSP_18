#!/bin/bash


oc create -f openstack_dataplane_nodeset_ovsdpdk.yaml 

oc create -f openstack_dataplane_nodeset_sriov.yaml

oc create -f openstack_dataplane_dpdk_deployment.yaml 

oc create -f openstack_dataplane_sriov_deployment.yaml 

#Provisioning should start on EDPM node
oc get bmh -n openshift-machine-api

#Check the status
oc get pods -l app=openstackansibleee
oc get openstackdataplanedeployment
oc get openstackdataplanenodeset


