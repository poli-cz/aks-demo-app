# AKS Demo App (from scratch)

Minimal FastAPI mock app + Docker image + Kubernetes manifests for AKS.
Designed as a clean baseline repo to later add Helm and Flux (GitOps).

## What’s inside
- `app/` FastAPI app with:
  - `/` (returns basic JSON)
  - `/healthz` (liveness)
  - `/readyz` (readiness)
- `Dockerfile` builds a small Python image
- `k8s/base/` Kubernetes manifests:
  - Namespace, ConfigMap, Secret, Deployment, Service (LoadBalancer), optional HPA
- `scripts/` helper scripts:
  - `az-push.sh` push image to ACR
  - `deploy.sh` apply manifests + rollout status
  - `stop.sh` stop pods + delete LB service (save money)
  - `start.sh` bring it back

## Prerequisites
- Docker
- Azure CLI (`az`)
- kubectl
- Access to AKS + ACR

## Build locally
```bash
docker build -t aks-demo-app:1.0.0 .
docker run --rm -p 8080:8080 aks-demo-app:1.0.0
# open http://localhost:8080/
