#!/bin/bash
# Install single-node K3s
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--node-ip 192.168.56.110 --write-kubeconfig-mode 644" sh -

# Wait for K3s to be ready
echo "Waiting for node to be ready..."
sleep 15

# Deploy all applications and ingress from the shared folder
kubectl apply -f /vagrant/confs/