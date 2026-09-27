# Docker Registry

Self-hosted Docker image registry with HTTPS support via Traefik.

## Overview

This module provides a production-ready Docker registry service that:
- Runs a Docker Registry (compatible with Docker Engine)
- Generates self-signed TLS certificates with proper SANs
- Exposes registry via Traefik with HTTPS on port 443
- Supports unlimited image sizes and long-running operations

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                    Client                           │
│          (docker push/pull registry.home)           │
└──────────────────┬──────────────────────────────────┘
                   │ HTTPS (port 443)
                   ▼
┌──────────────────────────────────────────────────────┐
│                  Traefik (k3s)                       │
│   - TLSStore: registry-home-tls                     │
│   - IngressRoute: routes Host(registry.home)        │
└──────────────────┬──────────────────────────────────┘
                   │ HTTP (port 5000)
                   ▼
┌──────────────────────────────────────────────────────┐
│              Docker Registry (NixOS)                 │
│   - Data: /home/docker-registry/data                │
│   - User: docker-registry                           │
│   - Port: 5000                                      │
└──────────────────────────────────────────────────────┘
```

## Components

### `certificate.nix`
Generates self-signed TLS certificate with proper SAN (Subject Alternative Name):
- CN: registry.home
- SAN: DNS:registry.home
- Validity: 365 days
- Key: RSA 4096-bit

Certificate is stored in `/var/lib/registry-certs/` and trusted system-wide.

### `registry.nix`
Docker Registry service configuration:
- Enabled by default, starts on boot
- Data directory: `/home/docker-registry/data`
- HTTP port: 5000 (localhost only)
- Features:
  - Image deletion enabled
  - Storage redirect disabled
  - Health checks enabled (storage driver validation)
  - JSON logging for better monitoring
- Resource limits:
  - Memory: 512M max, 400M high water mark
  - CPU: 200% quota (2 cores)
  - IO weight: 500 (normal priority)

### `registry.yaml`
Kubernetes manifests for Traefik integration:
- **Namespace**: registry
- **Secret**: registry-home-tls (contains cert + key)
- **TLSStore**: Default certificate for Traefik
- **IngressRoute**: Routes registry.home to Docker Registry
- **Service**: ExternalName pointing to 127.0.0.1:5000

## Usage

### Push an image to registry

```bash
# Tag image with registry hostname
docker tag myapp:latest registry.home/myapp:latest

# Push to registry
docker push registry.home/myapp:latest
```

### Pull an image from registry

```bash
docker pull registry.home/myapp:latest
```

### List images in registry

```bash
curl -k https://registry.home/v2/_catalog
```

### Delete an image

```bash
curl -k -X DELETE https://registry.home/v2/myapp/manifests/sha256:<digest>
```

## Configuration Files

| File | Purpose |
|------|---------|
| `default.nix` | Module composition and DNS setup |
| `certificate.nix` | Self-signed cert generation and system trust |
| `registry.nix` | Docker Registry service configuration |
| `registry.yaml` | Traefik IngressRoute and K8s manifests |

## Environment Setup

### k3s Integration

The registry is integrated with k3s in `server/k8s/registry.nix`:
```yaml
mirrors:
  registry.home:
    endpoint:
      - https://registry.home
configs:
  registry.home:
    tls:
      ca_file: /var/lib/registry-certs/registry.home.crt
```

This allows k3s to pull images from the registry with certificate validation.

### System Hosts Entry

`/etc/hosts` entry is configured:
```
127.0.0.1    registry.home
```

## Certificate Management

### Automatic Generation

Certificates are automatically generated during system build as a Nix derivation, ensuring reproducibility and consistency across system rebuilds.

### Manual Regeneration

To regenerate certificates after system rebuild:
```bash
sudo systemctl restart setup-registry-cert.service
```

### Viewing Certificate Details

```bash
openssl x509 -in /var/lib/registry-certs/registry.home.crt -text -noout
```

## Networking

### Firewall

Traefik handles HTTPS on port 443 (managed by k3s).
Docker Registry API listens on localhost:5000 (no external access).

### DNS Resolution

- `registry.home` resolves to `127.0.0.1` via `/etc/hosts`
- TLS certificate valid for `registry.home` and `localhost`

## Monitoring & Health Checks

### Health Check Status

The registry includes an automatic health check service that validates connectivity:
```bash
systemctl status docker-registry-health
journalctl -u docker-registry-health -f
```

### Resource Usage Monitoring

View current resource consumption:
```bash
# Memory usage
systemctl show docker-registry --property MemoryCurrent

# CPU accounting
systemctl show docker-registry --property CPUUsageNSec

# Full service status with metrics
systemctl status docker-registry
```

### Kubernetes Monitoring

The service includes Prometheus annotations for monitoring:
```bash
# Check Prometheus service discovery
kubectl get endpoints -A | grep docker-registry
```

### Registry API Health

Check registry API directly:
```bash
curl -k https://registry.home/v2/
```

Expected response: HTTP 200 (empty body)

### Logs

View registry logs with JSON formatting:
```bash
journalctl -u docker-registry -f
```

## Troubleshooting

### Certificate validation errors

Ensure certificate is properly trusted:
```bash
# Check if certificate is in system trust store
trust list | grep registry.home
```

### Registry not accessible

Check IngressRoute status:
```bash
kubectl get ingressroute -A | grep registry
kubectl describe ingressroute registry-home -n kube-system
```

### Images not accessible from k3s

Verify k3s registry configuration:
```bash
cat /etc/rancher/k3s/registries.yaml
```

### Health check service failing

If `docker-registry-health` service is failing:
```bash
# Check service status
systemctl status docker-registry-health

# View recent logs
journalctl -u docker-registry-health -n 20

# Test manually
curl -f http://localhost:5000/v2/ && echo "Health OK" || echo "Health FAILED"
```

### Out of memory errors

If registry is hitting memory limits:
```bash
# Check current limits
systemctl show docker-registry --property MemoryMax
systemctl show docker-registry --property MemoryHigh

# Monitor memory usage
watch -n 1 'systemctl show docker-registry --property MemoryCurrent'

# Increase limits in registry.nix if needed (e.g., MemoryMax = "1G")
```

## Storage

### Data Location

`/home/docker-registry/data` - Contains pushed images and manifests

### Disk Space

Monitor disk usage:
```bash
du -sh /home/docker-registry/data
```

## Performance Tuning

Current Traefik proxy settings:
- `client_max_body_size 0` - Unlimited upload size
- `proxy_read_timeout 900` - 15 min read timeout
- `proxy_send_timeout 900` - 15 min send timeout

These settings support large images and slow connections.

## Security Considerations

### Self-signed Certificate

This registry uses a self-signed certificate. For production use, consider:
- Using Let's Encrypt via cert-manager
- Using a proper CA certificate
- Ensuring all clients trust the certificate

### Access Control

Currently, the registry has no authentication. Consider:
- Adding Traefik basic auth
- Using a reverse proxy with OAuth2
- Running registry in a private network

## Related Components

- `server/docker-registry/` - This module
- `server/k8s/` - Kubernetes (k3s) configuration
- `server/docker/` - Docker daemon configuration
