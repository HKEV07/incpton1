#!/bin/bash
# Wait for master to generate the token
while [ ! -f /vagrant/scripts/node-token ]; do sleep 2; done
# Install Worker node pointing to Master IP
K3S_TOKEN=$(cat /vagrant/scripts/node-token)
curl -sfL https://get.k3s.io | K3S_URL=https://192.168.56.110:6443 K3S_TOKEN=$K3S_TOKEN INSTALL_K3S_EXEC="--node-ip 192.168.56.111" sh -