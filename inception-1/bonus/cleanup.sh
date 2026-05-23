#!/usr/bin/env bash

set -euo pipefail

echo "[1/6] Uninstalling GitLab Helm release (if present)..."
helm -n gitlab uninstall gitlab || true

echo "[2/6] Removing Argo CD application and namespace..."
kubectl -n argocd delete application --all --ignore-not-found || true
kubectl delete namespace argocd --ignore-not-found || true

echo "[3/6] Deleting GitLab and dev namespaces (and their resources)..."
kubectl delete namespace gitlab --ignore-not-found || true
kubectl delete namespace dev --ignore-not-found || true

echo "[4/6] Removing ingress-nginx resources..."
kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml --ignore-not-found || true
kubectl delete namespace ingress-nginx --ignore-not-found || true

echo "[4.1] Deleting ingress-nginx admission webhooks (if present)..."
# remove validating/mutating webhook configurations created by ingress-nginx to avoid webhook errors during reinstall
kubectl delete validatingwebhookconfiguration ingress-nginx-admission --ignore-not-found || true
kubectl delete mutatingwebhookconfiguration ingress-nginx-admission --ignore-not-found || true

# also attempt to delete any other webhook configs that include 'ingress-nginx' in their name
kubectl get validatingwebhookconfigurations -o name 2>/dev/null | grep ingress-nginx || true | xargs -r kubectl delete || true
kubectl get mutatingwebhookconfigurations -o name 2>/dev/null | grep ingress-nginx || true | xargs -r kubectl delete || true

echo "[5/6] Waiting for namespaces to terminate (timeout ~2 minutes)..."
for ns in gitlab argocd dev ingress-nginx; do
  printf "  checking %s...\n" "$ns"
  for i in {1..6}; do
    if ! kubectl get ns "$ns" >/dev/null 2>&1; then
      printf "    %s removed\n" "$ns"
      break
    fi
    sleep 2
  done
done

echo "[6/6] Deleting k3d cluster 'khbouych-cluster'..."
k3d cluster delete khbouych-cluster || true

echo "Cleanup finished. If you want to also remove local Docker volumes created by k3d, run:"
echo "  docker volume ls | grep k3d && docker volume rm <volume>"

exit 0
