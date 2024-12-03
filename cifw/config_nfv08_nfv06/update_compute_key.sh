ssh controller-0 oc get -nopenstack secret dataplane-ansible-ssh-private-key-secret -o json | jq -r '.data["ssh-privatekey"]' | base64 -d > /tmp/k
chmod 600 /tmp/k
