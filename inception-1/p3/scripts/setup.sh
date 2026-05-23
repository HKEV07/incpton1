#!/bin/bash

# 1. Create the K3d Cluster
# k3d is a lightweight Kubernetes distribution that runs in Docker containers. It allows us to quickly spin up a local Kubernetes cluster on our iMac without the overhead of a full VM.
# This is perfect for development and testing purposes, especially when we want to run Argo CD and our application in the same environment.

# Maps 8080 (Argo UI) and 8888 (App) to your iMac
echo "Creating K3d Cluster..."
k3d cluster create cluster-khbouych -p "8080:80@loadbalancer" -p "8888:8888@loadbalancer" --wait

# 2. Update context (Connect kubectl to k3d)
k3d kubeconfig merge cluster-khbouych --kubeconfig-switch-context 

# 3. Create Namespaces
kubectl create namespace argocd
kubectl create namespace dev

# # 4. Install Argo CD
echo "Installing Argo CD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 5. Wait for Argo CD UI to be ready
echo "Waiting for Argo CD UI..."
kubectl wait --for=condition=available --timeout=600s deployment/argocd-server -n argocd

# 6. Expose Argo CD UI
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

# 7. Print Credentials
PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "---------------------------------------------------"
echo "Part 3 Cluster is Ready!"
echo "URL: http://localhost:8080"
echo "User: admin | Pass: $PASS"
echo "Next step: kubectl apply -f confs/application.yaml"
echo "kubectl port-forward -n argocd svc/argocd-server 8080:443"

echo "---------------------------------------------------"
