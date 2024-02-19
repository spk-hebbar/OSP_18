#!/bin/bash

#Apply 'bm_deploy.yaml' CR
oc apply -f bm_deploy.yaml

#Check baremetal server registered and introspected
oc get bmh -n openshift-machine-api

#The state should be available

#Optional step to apply label to baremetal server if required and missed specifying in above yaml file
#oc label bmh -n openshift-machine-api nfv02 app=openstack
