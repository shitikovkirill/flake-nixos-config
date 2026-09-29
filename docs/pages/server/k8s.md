# Kubernetes (k3s)

Lightweight Kubernetes via k3s, paired with the local
[Docker Registry](./docker-registry.md). Pulled in via
`profiles/server-kube.nix`, which imports both `server/k8s` and
`server/docker-registry` together — they're bundled because k3s is
configured to pull images from `registry.home`.

## Overview

`server/k8s/` configures:
- `k3s` running as a `server` role node, data under `/home/k3s/data`
  (not the default `/var/lib/rancher`)
- `kubectl` and `kubernetes-helm` client tooling
- `registry.home` in `/etc/hosts` and as a `k3s` registry mirror, with TLS
  validated against the registry's own CA
- Startup ordering so k3s waits for both the network and the registry's
  certificate to be ready

## Components

`server/k8s/`:

| File | Purpose |
|---|---|
| `service.nix` | Creates the `k3s` system user, enables `services.k3s` (server role, custom data dir), orders it after networking + `setup-registry-cert.service` |
| `registry.nix` | Writes `/etc/rancher/k3s/registries.yaml` so k3s trusts and mirrors `registry.home` |
| `networking.nix` | `/etc/hosts` entry for `k3s.local`; opens TCP 6443 (Kubernetes API) |
| `environment.nix` | Packages: `kubectl`, `kubernetes-helm`, `k3s` |

## Why it's bundled with docker-registry

`registry.nix` here writes a `registries.yaml` mirror config pointing k3s
at `https://registry.home`, validated with
`/var/lib/registry-certs/registry.home.crt` — the same certificate
`server/docker-registry/certificates/default.nix` generates. Without that
registry actually running, `registries.yaml` points at nothing. `profiles/server-kube.nix`
imports both modules together for exactly this reason; splitting them would
make it easy to end up with a k3s node that can't pull images.

See [Docker Registry](./docker-registry.md) for the registry side of this
pairing — certificate generation, Traefik/nginx ingress, and its own
troubleshooting section.

## Usage

```bash
# Cluster status
kubectl get nodes
kubectl get pods -A

# Registry mirror is transparent — a normal image reference resolves through it
kubectl run test --image=registry.home/myapp:latest

# Helm
helm repo add ...
helm install ...
```

## Networking

- API server: `https://k3s.local:6443` (TCP 6443 open in the firewall,
  `k3s.local` resolves to `127.0.0.1` via `/etc/hosts`)
- Registry: `registry.home` — see [Docker Registry → Networking](./docker-registry.md#networking)

## Troubleshooting

### k3s won't start

Check it's actually waiting on the registry certificate, not failing outright:

```bash
systemctl status k3s
systemctl status setup-registry-cert.service
journalctl -u k3s -f
```

`server/k8s/service.nix` makes `k3s.service` `Requires=network-online.target`
and `Wants=setup-registry-cert.service` — if the registry cert generation is
stuck or failed, k3s will wait rather than start with a broken mirror config.

### Images won't pull from registry.home

```bash
cat /etc/rancher/k3s/registries.yaml
kubectl describe pod <pod> | grep -A5 Events
```

Confirms the mirror config is what `registry.nix` wrote, and shows the
actual pull error (usually a certificate trust issue — see
[Docker Registry → Troubleshooting](./docker-registry.md#troubleshooting)).

## Related Components

- [Docker Registry](./docker-registry.md) — `server/docker-registry/`, the registry this module mirrors from
- [Docker](./docker.md) — `server/docker/`, a separate standalone-Docker profile (`server-plain`), not used by k3s itself
- [Architecture](../architecture.md) — how `profiles/server-kube.nix` fits into a host's module list
