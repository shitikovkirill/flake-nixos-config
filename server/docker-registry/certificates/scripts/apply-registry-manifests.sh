#!/bin/bash
set -e

# Wait for Kubernetes API server
"${WAIT_FOR_K8S_SCRIPT:?WAIT_FOR_K8S_SCRIPT not set}"

# Apply registry manifests
kubectl apply -f "${REGISTRY_MANIFEST_PATH:?REGISTRY_MANIFEST_PATH not set}"
