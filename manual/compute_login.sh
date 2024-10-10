#!/bin/bash


oc get secret dataplane-ansible-ssh-private-key-secret -o json | jq -r '.data["ssh-privatekey"]' | base64 -d > /tmp/key_rsa
chmod 600 /tmp/key_rsa
ssh -i /tmp/key_rsa cloud-admin@192.168.122.100

