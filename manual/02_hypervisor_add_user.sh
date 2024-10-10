#!/bin/bash

# Enable command execution logging
set -x

# Create stack user
sudo useradd stack
sudo passwd stack

# Grant sudo privileges to stack without a password prompt using visudo
echo "stack ALL=(ALL) NOPASSWD: ALL" | sudo EDITOR="tee -a" visudo -f /etc/sudoers.d/stack

# Switch to the stack user and run setup script
su - stack -c 'bash -s' < stack_setup.sh


