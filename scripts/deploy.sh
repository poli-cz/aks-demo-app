#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="demo"

kubectl apply -f k8s/base/namespace.yaml
kubectl apply -f k8s/base/configmap.yaml
kubectl apply -f k8s/base/secret.yaml
kubectl apply -f k8s/base/deployment.yaml
kubectl apply -f k8s/base/service.yaml
# kubectl apply -f k8s/base/hpa.yaml  # enable later if you want autoscaling

kubectl -n "${NAMESPACE}" rollout status deploy/demo-app
kubectl -n "${NAMESPACE}" get pods -o wide
kubectl -n "${NAMESPACE}" get svc demo-app
