#!/bin/bash
# Install Master node
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--node-ip 192.168.56.110 --write-kubeconfig-mode 644" sh -
# Export the token so the worker can use it
sudo cat /var/lib/rancher/k3s/server/node-token > /vagrant/scripts/node-token