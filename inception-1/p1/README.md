# K3s Cluster Setup with Vagrant

## Overview
This project sets up a lightweight Kubernetes cluster using K3s with Vagrant and VirtualBox. It consists of one server node and one worker node communicating over a private network.

## Architecture

### Nodes
- **khalidS** (Server): 192.168.56.110
  - Master node running K3s server
  - 1GB RAM, 1 CPU
  
- **khalidSW** (Worker): 192.168.56.111
  - Worker node joining the cluster
  - 512MB RAM, 1 CPU

## Components

### Vagrantfile
Defines the virtual infrastructure:
- Base image: Ubuntu 22.04 (Jammy)
- Private network for inter-node communication
- Automatic provisioning scripts for each node

### install_k3s_server.sh
Runs on the server node to:
1. Download and install K3s server
2. Extract the node token (`/var/lib/rancher/k3s/server/node-token`)
3. Save token to `/vagrant/token` for worker access
4. Configure kubectl environment

### install_k3s_agent.sh
Runs on the worker node to:
1. Read the token from `/vagrant/token`
2. Join the K3s cluster using the server's IP (192.168.56.110:6443)

## Setup Instructions

```bash
# Start the cluster
vagrant up

# SSH into server
vagrant ssh khalidS

# SSH into worker
vagrant ssh khalidSW

# Check cluster status
kubectl get nodes
```

## File Structure
```
p1/
├── Vagrantfile
├── scripts/
│   ├── install_k3s_server.sh
│   └── install_k3s_agent.sh
└── README.md
```
