#!/bin/bash

SSH_ALGORITHM=${SSH_ALGORITHM:-"rsa"}
SSH_KEY_FILE=${SSH_KEY_FILE:-"ansibleee-ssh-key-id_rsa"}
SSH_KEY_SIZE=${SSH_KEY_SIZE:-"4096"}

if [ ! -f ${SSH_KEY_FILE} ]; then
	ssh-keygen -f ${SSH_KEY_FILE} -N "" -t ${SSH_ALGORITHM} -b ${SSH_KEY_SIZE}
fi

cat > dataplane-ssh-secret.yaml <<EOL
apiVersion: v1
data:
  authorized_keys: $(base64 -w 0 < ${SSH_KEY_FILE}.pub)
  ssh-privatekey: $(base64 -w 0 < ${SSH_KEY_FILE})
  ssh-publickey: $(base64 -w 0 < ${SSH_KEY_FILE}.pub)
kind: Secret
metadata:
  name: dataplane-ansible-ssh-private-key-secret
  namespace: openstack
EOL

echo "Secret YAML file created: dataplane-ssh-secret.yaml"

cat > nova-migration-ssh-key.yaml <<EOL
apiVersion: v1
data:
  ssh-privatekey: $(base64 -w 0 < ${SSH_KEY_FILE})
  ssh-publickey: $(base64 -w 0 < ${SSH_KEY_FILE}.pub)
kind: Secret
metadata:
  name: nova-migration-ssh-key
  namespace: openstack
type: kubernetes.io/ssh-auth/
EOL

echo "Secret YAML file created: nova-migration-ssh-key.yaml"

oc create -f dataplane-ssh-secret.yaml
oc create -f nova-migration-ssh-key.yaml
