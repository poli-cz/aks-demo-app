RG="rg-helm-flux-demo"
AKS="aks-helm-flux-demo"

az aks get-credentials -g "$RG" -n "$AKS" --overwrite-existing
kubectl get nodes
