#!/bin/bash
set -e

echo "[INFO] Starting apply-registry-manifests script"

# Wait for Kubernetes API server
echo "[INFO] Waiting for Kubernetes API server..."
"${WAIT_FOR_K8S_SCRIPT:?WAIT_FOR_K8S_SCRIPT not set}"
echo "[INFO] Kubernetes API server is ready"

# Get the host IP (first non-loopback IP address)
echo "[INFO] Detecting host IP address..."
# Try hostname -I first, then fall back to ip addr
HOST_IP=$(hostname -I 2>/dev/null | awk '{print $1}')
if [ -z "$HOST_IP" ]; then
  echo "[DEBUG] hostname -I returned empty, trying ip addr..."
  HOST_IP=$(ip addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '^127\.' | head -1)
fi
echo "[DEBUG] Detected host IP: '$HOST_IP'"

# Validate IP
if [ -z "$HOST_IP" ]; then
  echo "[ERROR] Could not detect host IP" >&2
  exit 1
fi

if ! echo "$HOST_IP" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'; then
  echo "[ERROR] Invalid IP address: $HOST_IP" >&2
  exit 1
fi

echo "[INFO] Using host IP: $HOST_IP"

# Create temporary manifest with actual host IP
echo "[INFO] Creating temporary manifest file..."
TEMP_MANIFEST=$(mktemp)
echo "[DEBUG] Temp manifest: $TEMP_MANIFEST"

MANIFEST_PATH="${REGISTRY_MANIFEST_PATH:?REGISTRY_MANIFEST_PATH not set}"
echo "[DEBUG] Source manifest: $MANIFEST_PATH"
echo "[DEBUG] Running sed to substitute HOST_IP_PLACEHOLDER with $HOST_IP"
sed "s/HOST_IP_PLACEHOLDER/$HOST_IP/g" "$MANIFEST_PATH" > "$TEMP_MANIFEST"

# Verify substitution worked
echo "[INFO] Verifying substitution..."
if grep -q "HOST_IP_PLACEHOLDER" "$TEMP_MANIFEST"; then
  echo "[ERROR] Failed to substitute HOST_IP_PLACEHOLDER with $HOST_IP" >&2
  echo "[DEBUG] Manifest content:"
  cat "$TEMP_MANIFEST" >&2
  rm -f "$TEMP_MANIFEST"
  exit 1
fi

echo "[DEBUG] Substitution successful"
echo "[DEBUG] Final manifest preview:"
head -20 "$TEMP_MANIFEST" | sed 's/^/[DEBUG] /'

# Apply registry manifests
echo "[INFO] Applying registry manifests to Kubernetes..."
kubectl apply -f "$TEMP_MANIFEST"
echo "[INFO] Manifests applied successfully"

# Clean up
echo "[INFO] Cleaning up temporary files..."
rm -f "$TEMP_MANIFEST"

echo "[INFO] apply-registry-manifests script completed successfully"
