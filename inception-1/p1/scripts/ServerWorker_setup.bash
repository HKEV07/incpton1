#!/bin/bash
apt update
apt install vim net-tools curl -y
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="agent --config /vagrant/confs/ServerWorker_config.yaml" sh
echo 'alias k="kubectl"' >> /home/vagrant/.bashrc
