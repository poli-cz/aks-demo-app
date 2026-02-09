# Azure Setup (AKS + ACR)

This document describes the Azure-side setup required to run this repository.

The application itself is fully described in Git, but Azure resources must exist before deployment.

---

## Azure Resources

### Azure Kubernetes Service (AKS)

- Kubernetes cluster used to run workloads
- Example:
  - Resource Group: rg-helm-flux-demo
  - Cluster name: aks-helm-flux-demo
  - Location: westeurope

AKS must be accessible via:

az aks get-credentials -g <RG> -n <AKS>

---

### Azure Container Registry (ACR)

Registry:
lakmoosacr.azurecr.io

Repositories:
- aks-demo-app

---

## AKS ↔ ACR Integration

az aks update -g <RG> -n <AKS> --attach-acr lakmoosacr

---

## Verification

az acr repository list -n lakmoosacr -o table
kubectl get nodes
