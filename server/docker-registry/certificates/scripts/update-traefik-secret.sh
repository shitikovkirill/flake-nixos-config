#!/bin/bash
set -e

echo "[INFO] Starting update-traefik-secret script"

CERT_DIR="${CERT_DIR:-/var/lib/registry-certs}"
echo "[INFO] Certificate directory: $CERT_DIR"

# Wait for Kubernetes API server
echo "[INFO] Waiting for Kubernetes API server..."
"${WAIT_FOR_K8S_SCRIPT:?WAIT_FOR_K8S_SCRIPT not set}"
echo "[INFO] Kubernetes API server is ready"

# Verify certificate files exist
echo "[INFO] Checking certificate files..."
if [ ! -f "$CERT_DIR/registry.home.crt" ]; then
  echo "[ERROR] Certificate file not found: $CERT_DIR/registry.home.crt" >&2
  exit 1
fi
if [ ! -f "$CERT_DIR/registry.home.key" ]; then
  echo "[ERROR] Key file not found: $CERT_DIR/registry.home.key" >&2
  exit 1
fi
echo "[INFO] Certificate files verified"

# Read and encode certificates
echo "[INFO] Encoding certificate and key..."
CERT=$(cat "$CERT_DIR/registry.home.crt" | base64 -w0)
KEY=$(cat "$CERT_DIR/registry.home.key" | base64 -w0)
echo "[DEBUG] Certificate size: ${#CERT} characters"
echo "[DEBUG] Key size: ${#KEY} characters"

# Delete existing secret to force regeneration
echo "[INFO] Deleting existing secret (if any)..."
kubectl delete secret registry-home-tls -n kube-system --ignore-not-found=true
echo "[INFO] Old secret deleted"

# Create temporary Secret manifest
echo "[INFO] Creating secret manifest..."
MANIFEST="/tmp/registry-secret.yaml"
cat > "$MANIFEST" << EOF
apiVersion: v1
kind: Secret
metadata:
  name: registry-home-tls
  namespace: kube-system
type: kubernetes.io/tls
data:
  tls.crt: $CERT
  tls.key: $KEY
EOF
echo "[DEBUG] Manifest created at: $MANIFEST"

# Apply the secret
echo "[INFO] Applying secret to Kubernetes..."
kubectl apply -f "$MANIFEST"
echo "[INFO] Secret applied successfully"

# Verify secret was created
echo "[INFO] Verifying secret creation..."
if kubectl get secret registry-home-tls -n kube-system >/dev/null 2>&1; then
  echo "[INFO] Secret verified in Kubernetes"
else
  echo "[ERROR] Secret was not created properly" >&2
  exit 1
fi

# Clean up
echo "[INFO] Cleaning up temporary files..."
rm -f "$MANIFEST"

echo "[INFO] update-traefik-secret script completed successfully"
