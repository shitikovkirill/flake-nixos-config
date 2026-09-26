#!/bin/bash
set -e

# Wait for Kubernetes API server
"$(dirname "$0")/wait-for-k8s.sh"

# Apply registry manifests
kubectl apply -f "${REGISTRY_MANIFEST_PATH:?REGISTRY_MANIFEST_PATH not set}"
