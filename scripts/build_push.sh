#!/usr/bin/env bash
set -euo pipefail

IMAGE="${IMAGE:-ghcr.io/YOUR_ORG/aks-demo-app}"
TAG="${1:-1.0.0}"

echo "Building ${IMAGE}:${TAG}"
docker build -t "${IMAGE}:${TAG}" .

echo "Pushing ${IMAGE}:${TAG}"
docker push "${IMAGE}:${TAG}"

echo "Done."
