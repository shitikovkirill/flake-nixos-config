#!/bin/bash
set -e

CERT_DIR="${CERT_DIR:-/var/lib/registry-certs}"

# Wait for Kubernetes API server
"${WAIT_FOR_K8S_SCRIPT:?WAIT_FOR_K8S_SCRIPT not set}"

CERT=$(cat "$CERT_DIR/registry.home.crt" | base64 -w0)
KEY=$(cat "$CERT_DIR/registry.home.key" | base64 -w0)

# Delete existing secret to force regeneration
kubectl delete secret registry-home-tls -n kube-system --ignore-not-found=true

# Create temporary Secret manifest
cat > /tmp/registry-secret.yaml << EOF
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

# Apply the secret
kubectl apply -f /tmp/registry-secret.yaml

# Clean up
rm -f /tmp/registry-secret.yaml
