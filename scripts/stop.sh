#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-demo}"
APP="${APP:-demo-app}"

echo "Stopping ${APP} in namespace ${NAMESPACE}..."

# 1) Remove external exposure first (frees Azure LB + public IP)
if kubectl -n "${NAMESPACE}" get svc "${APP}" >/dev/null 2>&1; then
  echo "Deleting Service ${APP} (LoadBalancer)..."
  kubectl -n "${NAMESPACE}" delete svc "${APP}"
else
  echo "Service ${APP} not found, skipping."
fi

# 2) Scale deployment to 0 (stops pods)
if kubectl -n "${NAMESPACE}" get deploy "${APP}" >/dev/null 2>&1; then
  echo "Scaling Deployment ${APP} to 0 replicas..."
  kubectl -n "${NAMESPACE}" scale deploy "${APP}" --replicas=0
else
  echo "Deployment ${APP} not found, skipping."
fi

echo ""
echo "Current resources:"
kubectl -n "${NAMESPACE}" get deploy,rs,pods,svc || true

echo ""
echo "✅ Stopped. No pods should be running, and the LoadBalancer should be deleted."
