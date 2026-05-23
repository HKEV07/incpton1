k3d cluster delete mycluster
k3d cluster create mycluster --servers 1 \
      --agents 1 --k3s-arg \
      "--disable=traefik@server:*" \ 
      -p "80:80@loadbalancer" \
      -p "443:443@loadbalancer" \
      -p "8888:30001@loadbalancer"

helm repo add gitlab https://charts.gitlab.io/
helm repo update

kubectl create namespace argocd
kubectl create namespace dev
kubectl create namespace gitlab


kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml


kubectl apply -n argocd --server-side -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml


cd ../confs
helm install gitlab gitlab/gitlab \
  -n gitlab \
  -f values.yaml

kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
kubectl wait --for=condition=available --timeout=600s deployment/gitlab-webservice-default -n gitlab

kubectl apply -f Application.yaml -f ingress.yaml

PASS_ACD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
PASS_GITLAB=$(kubectl -n gitlab get secret gitlab-gitlab-initial-root-password -o jsonpath="{.data.password}" | base64 -d)

echo "============================================================"
echo "🎯 SETUP COMPLETE"
echo "Username: admin | Pass: $PASS_ACD"
echo "------------------------------------------------------------"
echo "Username: root | Pass: $PASS_GITLAB"
echo "------------------------------------------------------------"
