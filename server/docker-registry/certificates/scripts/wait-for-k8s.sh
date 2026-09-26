#!/bin/bash
set -e

for i in {1..60}; do
  if kubectl --kubeconfig=/etc/rancher/k3s/k3s.yaml cluster-info &>/dev/null; then
    exit 0
  fi
  echo "Waiting for Kubernetes API server... ($i/60)"
  sleep 1
done
echo "Kubernetes API server did not become ready after 60 seconds"
exit 1
