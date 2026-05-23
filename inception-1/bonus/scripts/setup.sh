#!/usr/bin/env bash

set -euo pipefail

echo "[1/9] Recreating k3d cluster..."
k3d cluster delete khbouych-cluster 
k3d cluster create khbouych-cluster --servers 1 --agents 1 --k3s-arg "--disable=traefik@server:*" -p "8888:30002@loadbalancer" -p "80:80@loadbalancer" -p "443:443@loadbalancer"

echo "[2/9] Adding/updating Helm repo for GitLab..."
helm repo add gitlab https://charts.gitlab.io/ 
helm repo update

echo "[3/9] Creating namespaces: argocd, dev, gitlab..."
kubectl create namespace argocd 
kubectl create namespace dev 
kubectl create namespace gitlab 

echo "[4/9] Installing ingress-nginx controller..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml
kubectl wait --for=condition=available --timeout=90s deployment/ingress-nginx-controller -n ingress-nginx

echo "[5/9] Installing Argo CD..."
kubectl apply -n argocd --server-side -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "[6/9] Installing GitLab via Helm (this may take several minutes)..."
helm install gitlab gitlab/gitlab \
  -n gitlab \
  --version 9.4.0 \
  -f ../confs/values.yaml \
  --set certmanager-issuer.email=ibenaait@gmail.com

echo "[7/9] Waiting for Argo CD and GitLab deployments to become available..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
kubectl wait --for=condition=available --timeout=600s deployment/gitlab-webservice-default -n gitlab

echo "[8/9] Applying application and ingress manifests..."
kubectl apply -f ../confs/Application.yaml -f ../confs/ingress.yaml

echo "[9/9] Retrieving initial passwords..."
PASS_ACD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
PASS_GITLAB=$(kubectl -n gitlab get secret gitlab-gitlab-initial-root-password -o jsonpath="{.data.password}" | base64 -d)

echo "============================================================"
echo "🎯 SETUP COMPLETE"
echo "Username: admin | Pass: $PASS_ACD"
echo "------------------------------------------------------------"
echo "Username: root | Pass: $PASS_GITLAB"
echo "------------------------------------------------------------"
