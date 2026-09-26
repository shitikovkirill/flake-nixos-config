#!/bin/bash
set -e

# Wait for Kubernetes API server
"${WAIT_FOR_K8S_SCRIPT:?WAIT_FOR_K8S_SCRIPT not set}"

# Get the host IP (first non-loopback IP address)
HOST_IP=$(hostname -I | awk '{print $1}')

# Create temporary manifest with actual host IP
TEMP_MANIFEST=$(mktemp)
sed "s/HOST_IP_PLACEHOLDER/$HOST_IP/g" "${REGISTRY_MANIFEST_PATH:?REGISTRY_MANIFEST_PATH not set}" > "$TEMP_MANIFEST"

# Apply registry manifests
kubectl apply -f "$TEMP_MANIFEST"

# Clean up
rm -f "$TEMP_MANIFEST"
