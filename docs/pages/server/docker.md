# Docker

Standalone Docker daemon — CLI, packages, cleanup automation, and a
TLS-secured remote API. Pulled in via `profiles/server-plain.nix`.

## Overview

`server/docker/` configures:
- The Docker daemon itself, running as a dedicated `docker` system user
  with its data under `/home/docker/data` (not the default `/var/lib/docker`)
- A CA + server + client TLS certificate pair, generated on first boot, so
  the remote API is never exposed without client-cert authentication
- `lazydocker`, `kubectl` (useful even without k3s, e.g. against a remote
  cluster), and Docker/Compose zsh plugins
- Periodic cleanup timers for build cache, dangling images, and dangling
  volumes
- A large set of `d*`/`dr*`/`dclean-*` shell aliases

It does **not** include Kubernetes — see [Kubernetes](./k8s.md) for that,
and [Docker Registry](./docker-registry.md) for the paired registry (which
is bundled with k3s in `profiles/server-kube.nix`, not here, since it's a
kube-registry mirror pairing rather than a Docker-daemon one).

## Components

`server/docker/`:

| File | Purpose |
|---|---|
| `service.nix` | Creates the `docker` system user/group, configures `virtualisation.docker` (data root, TLS daemon settings) |
| `tls.nix` | Generates the CA/server/client certificate pair on first boot |
| `cleanup.nix` | systemd timers for cache/image/volume pruning + related aliases |
| `environment.nix` | Packages (`docker`, `lazydocker`, `kubectl`), zsh plugins, Docker-command aliases |
| `networking.nix` | Opens TCP 2376 (TLS-only remote API port) |

## TLS-secured remote API

The daemon listens on both the local Unix socket and
`tcp://0.0.0.0:2376` with `tlsverify = true` — **not** the classic
unauthenticated `2375`. See
[Architecture → Security Considerations](../architecture.md#security-considerations)
for why: an open `2375` gives anyone on the same network root-equivalent
control of the host.

### How the certificates are generated

`docker-tls-certs.service` (a systemd oneshot, `Before=docker.service`,
`ConditionPathExists=!/home/docker/certs/ca.pem`) runs as the `docker` user
and, only if `ca.pem` doesn't already exist:

1. Generates a self-signed CA (`ca-key.pem` / `ca.pem`)
2. Generates a server cert signed by that CA, SAN'd for the host's
   `networking.hostName` and `0.0.0.0` (`server-key.pem` / `server-cert.pem`)
3. Generates a client cert signed by that CA (`client-key.pem` /
   `client-cert.pem`)

All six files land in `/home/docker/certs/`, **never** in the Nix store —
private keys there would be world-readable at `/nix/store/...` forever,
even after rotation. `chmod 0400` on the three key files, `0444` on the
three certs.

### Connecting a client to this daemon

Copy `ca.pem`, `client-cert.pem`, and `client-key.pem` from
`/home/docker/certs/` on this host to `~/.docker/certs/` on the machine you
want to control the daemon from, renaming them to Docker's expected
filenames (`ca.pem`, `cert.pem`, `key.pem`):

```bash
scp <this-host>:/home/docker/certs/ca.pem          ~/.docker/certs/ca.pem
scp <this-host>:/home/docker/certs/client-cert.pem ~/.docker/certs/cert.pem
scp <this-host>:/home/docker/certs/client-key.pem  ~/.docker/certs/key.pem

export DOCKER_HOST=tcp://<this-host>:2376
export DOCKER_TLS_VERIFY=1
export DOCKER_CERT_PATH=~/.docker/certs

docker ps   # now talks to the remote daemon
```

### Regenerating certificates

Delete `/home/docker/certs/ca.pem` (or the whole directory) and restart the
service — it only (re)generates when `ca.pem` is missing:

```bash
sudo rm -rf /home/docker/certs
sudo systemctl restart docker-tls-certs.service
sudo systemctl restart docker.service
```

Any previously distributed client certs stop working once the CA is
regenerated — redistribute the new `ca.pem`/`client-cert.pem`/`client-key.pem`
to every machine that talks to this daemon.

## Cleanup automation

| Timer | Schedule | Action |
|---|---|---|
| `docker-cleanup-cache` | Weekly, Sun 02:00 | `docker builder prune -af` |
| `docker-cleanup-images` | Daily, 03:00 | `docker image prune -af` |
| `docker-cleanup-volumes` | Weekly, Mon 02:30 | `docker volume prune -af` |

All three are `-a` (remove everything unused, not just dangling) and `-f`
(no confirmation) — intentionally aggressive, meant for a server that
doesn't need to keep build caches around between unrelated projects.
Trigger manually with `dclean-cache`/`dclean-images`/`dclean-volumes`/
`dclean-all`, check status with `dclean-status`.

## Shell aliases

| Alias | Does |
|---|---|
| `dhist` | `docker history --no-trunc` |
| `dlint` | Lint a `Dockerfile` via `hadolint` in a throwaway container |
| `dlint-deb` | Same, Debian-flavored hadolint image |
| `dpoetry` | Drop into a bash shell with Poetry available, cwd mounted |
| `drmc` / `drimage` / `drdimage` / `drvolume` / `drnetwork` | Remove stopped containers / all images / dangling images / dangling volumes / prune networks |
| `dclearall` | `docker system prune -a -f` — nuclear option |
| `dstopc` / `dnorestart` | Stop all containers / disable their restart policy |
| `dstopc_with_restart_always` | Stop everything, disable restart policy, restart the daemon |
| `azurite` | Run the Azure Storage emulator container |
| `mk_start`/`mk_con`/`mk_context`/`mk_ip`/`mk_dash` | Minikube shortcuts — **dead**, `minikube` isn't installed by this module; kept from the pre-flake config, k3s (see [Kubernetes](./k8s.md)) is the actual Kubernetes path now |

## Related Components

- [Kubernetes](./k8s.md) — `server/k8s/`, the actual Kubernetes path (k3s, not minikube)
- [Docker Registry](./docker-registry.md) — `server/docker-registry/`, bundled with k8s, not this module
- [Architecture](../architecture.md) — how `profiles/server-plain.nix` fits into a host's module list
