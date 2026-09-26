#!/bin/bash
set -e

REGISTRY_DIR="${REGISTRY_DIR:-$(dirname "$0")/.."}"

# Wait for Kubernetes API server
"$(dirname "$0")/wait-for-k8s.sh"

# Apply registry manifests
kubectl apply -f "$REGISTRY_DIR/registry.yaml"
