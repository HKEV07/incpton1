#!/usr/bin/env bash

apt-get update
apt-get install -y curl 
curl -fsSL https://get.docker.com | sh
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && chmod +x kubectl && sudo mv kubectl /usr/local/bin/
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

sudo usermod -aG docker hkev

