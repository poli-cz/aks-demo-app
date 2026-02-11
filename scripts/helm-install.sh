kubectl create namespace demo 2>/dev/null || true

helm lint helm/aks-demo-app

helm install demo helm/aks-demo-app \
  -n demo \
  --create-namespace \
  -f helm/aks-demo-app/values-dev.yaml
