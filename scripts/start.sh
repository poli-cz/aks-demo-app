#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-demo}"
APP="${APP:-demo-app}"

echo "Starting ${APP} in namespace ${NAMESPACE}..."

# ensure base resources exist
kubectl apply -f k8s/base/namespace.yaml
kubectl apply -f k8s/base/configmap.yaml
kubectl apply -f k8s/base/secret.yaml
kubectl apply -f k8s/base/deployment.yaml

# scale up
kubectl -n "${NAMESPACE}" scale deploy "${APP}" --replicas=2

# recreate service (LB)
kubectl apply -f k8s/base/service.yaml

kubectl -n "${NAMESPACE}" rollout status deploy/"${APP}"
kubectl -n "${NAMESPACE}" get svc "${APP}"
