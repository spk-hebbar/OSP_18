#!/bin/bash

#Run this script as ". 03_ocp_setup.sh" to apply the env to parent shell

#Get it from https://console.redhat.com/openshift/create/local
export NEXTGEN_PULL_SECRET=$(cat "${HOME}/pull_secret")

#Get it from https://oauth-openshift.apps.ci.l2s4.p1.openshiftapps.com/oauth/token/display
export NEXTGEN_INTERNAL_CI_TOKEN=$(cat "${HOME}/ci_token") 

cat > $HOME/src/dev-scripts/config_$USER.sh << EOF
set +x
export CI_TOKEN=${NEXTGEN_INTERNAL_CI_TOKEN}
set -x
export WORKING_DIR=/home/stack/dev-scripts
export OPENSHIFT_RELEASE_STREAM="4.16.0"
export OPENSHIFT_RELEASE_TYPE=ga
export OPENSHIFT_VERSION="4.16.0"
export CLUSTER_NAME="ocp"
export BASE_DOMAIN="openstack.lab"
export IP_STACK=v4
export NTP_SERVERS="clock.corp.redhat.com"
export PROVISIONING_NETWORK_PROFILE=Managed
export PROVISIONING_HOST_EXTERNAL_IP="192.168.111.1" #ocpbm, Try 10.8.2.186 if this doesn't work
export PROVISIONING_URL_HOST=${PROVISIONING_HOST_EXTERNAL_IP}
export EXT_IF="eno1"
export PRO_IF="eno2" #ocppr
export INT_IF="enp196s0f0np0" #ocpbm
export OSP_TRUNK_IF="enp196s0f1np1" #osp_trunk
export OSP_EXTERNAL_IF="eno2.1501" #osp_external
export EXTERNAL_SUBNET_V4="192.168.111.0/24" #ocpbm
export NETWORK_TYPE="OpenShiftSDN"
export CLUSTER_SUBNET_V4="192.168.16.0/20"
export CLUSTER_HOST_PREFIX_V4="22"
export SERVICE_SUBNET_V4="172.30.0.0/16"
export PROVISIONING_NETWORK="172.22.0.0/24"
export EXTRA_NETWORK_NAMES="osp_trunk osp_external"
export OSP_TRUNK_NETWORK_SUBNET_V4='192.168.122.0/24' #osp_trunk
export OSP_EXTERNAL_NETWORK_SUBNET_V4='192.168.10.0/24' #osp_external
export BMC_DRIVER=ipmi
export SSH_PUB_KEY='$(cat ${HOME}/.ssh/id_rsa.pub)'

# Deploy 3 OpenShift nodes, masters are workers
export NUM_MASTERS=3
export MASTER_MEMORY=16384 
export MASTER_DISK=100
export MASTER_VCPU=10
export NUM_WORKERS=0
EOF

echo $NEXTGEN_PULL_SECRET > $HOME/src/dev-scripts/pull_secret.json
