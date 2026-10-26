# System Architecture

## Overview

flake-nixos-config is a declarative NixOS system configuration that combines:
- Desktop environments and applications
- Server services (Docker, Kubernetes/k3s, a self-hosted registry)
- Opt-in development tooling, organized as **profiles**
- System-wide configuration management shared by every host

## Directory Structure

```
flake-nixos-config/
├── hosts/                       # Per-machine, per-role configs
│   ├── asus-n56vj/                 # hardware-configuration.nix + common/desktop/server.nix
│   └── asus-n580vn/                 # hardware-configuration.nix + common/desktop.nix
├── profiles/                    # Named, opt-in package sets — each host lists
│   │                             # the ones it wants explicitly in flake.nix.
│   │                             # Nothing here is implied by sharedModules.
│   ├── minimal-dev.nix            # bash, git, direnv, h, VS Code, ai/MCP, network
│   ├── nix-dev.nix                # Nix-the-language tooling (niv, nixfmt, ...)
│   ├── python-dev.nix             # development/python + its ide/ (PyCharm)
│   ├── go-dev.nix                 # development/go + its ide/ (GoLand)
│   ├── js-dev.nix                 # development/js + its ide/ (WebStorm)
│   ├── db-dev.nix                 # development/db/* — see the Databases section below
│   ├── ide-tools.nix              # bruno, postman, xmind, RubyMine/PhpStorm reset scripts
│   ├── electronics-dev.nix        # arduino, rpi-imager — opt-in, not on any host yet
│   ├── server-kube.nix            # server/k8s + server/docker-registry (coupled)
│   └── server-plain.nix           # server/docker (standalone, no k8s)
├── desktop/                     # UI applications
│   ├── environments/               # xfce, plasma5, plasma6
│   ├── audio.nix                    # pipewire (shared by every desktop host)
│   ├── apps/                        # browser, games, media, social, torrents
│   └── default.nix
├── server/                      # Server applications (pulled in via profiles/server-*.nix)
│   ├── docker/                     # Docker daemon + TLS cert generation, see docs/pages/server/docker.md
│   ├── docker-registry/            # Self-hosted registry, see docs/pages/server/docker-registry.md
│   ├── ecs-anywhere/               # ECS Anywhere (toggleable), see docs/pages/server/ecs-anywhere.md
│   ├── k8s/                        # k3s, see docs/pages/server/k8s.md
│   ├── pkgs/                       # VPN client + utilities (shared by every host, any role)
│   └── default.nix
├── development/                 # Raw tool/package definitions, split by language.
│   │                             # NOT wired to any host directly — see profiles/.
│   │                             # A tool that isn't specific to one language lives
│   │                             # under common/ instead of a language directory.
│   ├── common/                     # Cross-language / not-a-language tooling
│   │   ├── ai/                        # AI/ML tools, MCP servers for Claude Code
│   │   ├── bash.nix                   # bash completion, history size
│   │   ├── direnv/
│   │   ├── electronics.nix            # arduino, rpi-imager
│   │   ├── git/
│   │   ├── h/                         # directory-jump tool
│   │   ├── ide/
│   │   │   ├── client.nix              # VS Code (desktop)
│   │   │   └── server/                 # VS Code Remote-SSH server support
│   │   ├── network/                   # private /etc/hosts entries + dev firewall ports
│   │   ├── nix-ld.nix                 # run dynamically-linked non-NixOS binaries
│   │   └── tools/
│   │       ├── reset-jetbrains.nix     # shared helper — see "JetBrains reset scripts" below
│   │       └── shell.nix               # standalone nix-shell entrypoint, not wired anywhere
│   ├── db/                         # split per-engine, see the Databases section below
│   │   ├── ide/                       # DBeaver + DataGrip (engine-agnostic)
│   │   ├── postgres/
│   │   ├── mysql/
│   │   ├── redis/
│   │   │   └── ide/                    # RedisInsight
│   │   └── mongo/
│   │       └── ide/                    # MongoDB Compass, Robo 3T
│   ├── go/
│   │   └── ide/                       # GoLand + reset script
│   ├── js/
│   │   └── ide/                       # WebStorm + reset script
│   ├── nix/                        # niv, nox, nix-index, nixfmt, nix-prefetch-git, ...
│   └── python/
│       └── ide/                       # PyCharm + reset script
├── system/                      # System configuration, shared by every host
│   ├── data/                       # Declarative user list (system/data/users.nix)
│   └── users/                      # Turns that list into actual users.users + MOTD
├── docs/                        # Documentation (Sphinx + MyST)
└── flake.nix                    # Flake configuration — wires hosts to profiles
```

### Hosts and role variants

Each `hosts/<name>/` directory holds everything specific to one physical
machine: `hardware-configuration.nix` (disks, kernel modules — generated
once by `nixos-generate-config`, not hand-edited), `common.nix` (bootloader,
hostname, networking, locale, timezone/stateVersion overrides — shared by
every role on that machine), and one file per role (`desktop.nix`,
`server.nix`).

`flake.nix` exposes one `nixosConfigurations` entry per host+role
combination:

| `nixosConfigurations` | Host | Role | Dev profiles | Extra |
|---|---|---|---|---|
| `asus-n56vj-desktop` | asus-n56vj | GUI workstation | `hosts/asus-n56vj/profiles.nix` | — |
| `asus-n56vj-server` | asus-n56vj | Headless docker/k3s box | `hosts/asus-n56vj/profiles.nix` | `server-kube` + `server-plain` + VS Code server |
| `asus-n580vn-desktop` | asus-n580vn | GUI workstation | `hosts/asus-n580vn/profiles.nix` | `server-plain` |

`asus-n56vj` runs two roles on the same hardware from the same repo,
without either role's modules active in the other — both roles share the
same `hosts/asus-n56vj/profiles.nix` toggle file, so switching role doesn't
change which dev tools are active.

### Profiles: opt-in package sets, toggled per host

`development/` and parts of `server/` hold raw tool definitions but are
**not** imported by any shared module — a host only gets a given tool set by
listing the matching `profiles/*.nix` file explicitly. This replaced an
earlier design where `development/default.nix` unconditionally pulled in a
fixed list of tools for every host, and a later `commonDevProfiles` list in
`flake.nix` that force-included the same seven profiles everywhere.

Instead, each host has its own `hosts/<name>/profiles.nix` — one line per
`profiles/*.nix` file that exists, all commented out except `minimal-dev`:

```nix
# hosts/asus-n56vj/profiles.nix
{
  imports = [
    ../../profiles/minimal-dev.nix
    # ../../profiles/nix-dev.nix
    # ../../profiles/python-dev.nix
    # ../../profiles/go-dev.nix
    # ../../profiles/js-dev.nix
    # ../../profiles/db-dev.nix
    # ../../profiles/ide-tools.nix
    # ../../profiles/electronics-dev.nix
  ];
}
```

Turning a profile on or off for one host is a one-line comment toggle in
that host's own file — no `flake.nix` edit, no risk of accidentally
changing another host's tool set. `server-kube`/`server-plain` are the
exception: they're wired directly per role in `flake.nix` rather than
through the per-host toggle file, since they define what a *role* is
(headless docker/k3s box) rather than a personal tool preference — though
`asus-n580vn-desktop` shows that's just a default, not a hard rule; it adds
`server-plain` directly even though its role is "desktop".

See [Development Environment](./development/development.md) for the full
profile-by-profile breakdown.

### JetBrains reset scripts

`development/common/tools/reset-jetbrains.nix` is a plain Nix function (not
a NixOS module) — `{ writeShellScriptBin }: { reset = name: ...; }` — that
every language's `ide/` module and `profiles/ide-tools.nix` import
individually to build a `reset-<IDE>` binary. It clears a JetBrains IDE's
evaluation-license state and predates this repo's current form; it's
carried forward as-is.

### Databases: `development/db/`

Split per engine, following the same "language directory + not-specific →
common" rule as the programming-language directories, just with database
engines instead of languages:

| Directory | Engine-specific content |
|---|---|
| `db/postgres/` | `postgresql` (CLI: `psql`) |
| `db/mysql/` | `mariadb` (CLI: `mysql`) — no client-only attribute exists in nixpkgs, this pulls in the full server+client package |
| `db/redis/` | `redis` (CLI: `redis-cli`) + `db/redis/ide/` (RedisInsight) |
| `db/mongo/` | `mongosh` (CLI) + `db/mongo/ide/` (MongoDB Compass, Robo 3T — Mongo-specific GUIs) |
| `db/ide/` | DBeaver + DataGrip — **not** engine-specific (both work across Postgres/MySQL/etc. in one product), so they live at the `db/` top level rather than under one engine |

`profiles/db-dev.nix` imports all of the above. A GUI tool only gets its
own `ide/` subdirectory when it's actually tied to one engine (Compass/Robo
3T → Mongo only, RedisInsight → Redis only); cross-engine tools like DBeaver
and DataGrip stay at `db/ide/`.

## Component Architecture

### Desktop Layer
- **Environments**: Multiple desktop environments (XFCE, KDE Plasma 5/6)
- **Applications**: User-facing applications (browser, media, social, games/torrents — the latter two opt-in, commented out of `desktop/default.nix`)
- **Audio**: pipewire, shared by every desktop host via `desktop/audio.nix`

### Server Layer
- **[`profiles/server-kube.nix`](./server/k8s.md)**: k3s cluster + [docker-registry](./server/docker-registry.md) (coupled — k3s pulls images from `registry.home`)
- **[`profiles/server-plain.nix`](./server/docker.md)**: standalone Docker daemon, TLS-only remote API, no Kubernetes
- **[ECS Anywhere](./server/ecs-anywhere.md)**: toggleable module that registers the host as an external ECS container instance
- **Utilities**: VPN client (`server/pkgs`), on every host regardless of role

### Development Layer
See [Development Environment](./development/development.md) for the full
profile list and directory-by-directory breakdown. Broadly: AI/ML (MCP
integration for Claude Code), database clients (SQL + NoSQL), Python/Go/
JS/Nix language tooling with per-language JetBrains IDEs, cross-language
tools that don't fit one language, and Git/shell/direnv baseline config —
each gated behind its own `profiles/*.nix`.

### System Layer
- **Users**: declared once in `system/data/users.nix`, turned into real
  `users.users` (+ SSH keys, MOTD) by `system/users/`
- **Aliases**: `system/aliases.nix`, shared by every host
- **Configuration**: `nixpkgs.config.allowUnfree`, `time.timeZone`,
  `nix.settings.experimental-features` — all set once in `system/default.nix`
  rather than per-host

## Service Integration

### Docker Registry

See [Docker Registry](./server/docker-registry.md) for the full
architecture diagrams (with/without k3s), certificate generation, and
troubleshooting. Summary:

```
Client → HTTPS → Traefik (k3s) or nginx (no k3s) → HTTP:5000 → Docker Registry
```

### Kubernetes Integration

See [Kubernetes](./server/k8s.md). Summary: k3s provides the cluster,
Traefik serves as ingress controller, and it's configured to mirror images
through the local registry above rather than pulling from the internet
directly.

### Docker (standalone)

See [Docker](./server/docker.md). Summary: a separate profile
(`server-plain`) from Kubernetes — a plain Docker daemon with a TLS-secured
remote API (client-cert auth on port 2376, generated on first boot,
private keys never touch the Nix store).

## Certificate Management

Two independent certificate-generation mechanisms exist, both as systemd
oneshot services that only (re)generate when their output is missing —
neither touches the Nix store, since private keys there would be
world-readable forever:

- **Registry TLS** (`server/docker-registry/certificates/`): self-signed
  cert with a proper SAN for `registry.home`, trusted system-wide via
  `security.pki.certificateFiles`. See
  [Docker Registry → Certificate Management](./server/docker-registry.md#certificate-management).
- **Docker remote-API TLS** (`server/docker/tls.nix`): a full CA + server +
  client cert chain under `/home/docker/certs/`, for client-cert
  authentication rather than system-wide trust. See
  [Docker → TLS-secured remote API](./server/docker.md#tls-secured-remote-api).

## Configuration Management

All configuration is declarative using:
- **Nix language** for configuration as code
- **Flakes** for reproducible, versioned environments — `flake.lock` pins
  `nixpkgs`, `home-manager`, and the local `docs` flake
- **Profiles** (`profiles/*.nix`) for opt-in composition instead of one
  fixed module every host gets
- **systemd** for service management, including one-shot generation of
  secrets/certificates that must not live in the Nix store

## Dependencies

### Build-time
- Nix package manager with flakes support (`nix.settings.experimental-features`, set in `system/default.nix`)
- openssl for certificate generation (registry + Docker TLS)

### Runtime
- NixOS operating system
- systemd for service management
- k3s for Kubernetes features (server-kube hosts only)
- Docker for container runtime (server-kube and server-plain hosts)

## How It All Works Together

1. **System Boot**
   - NixOS evaluates `flake.nix`, resolving each host's `sharedModules` + chosen `profiles/*.nix` + host-specific files
   - Services start in dependency order
   - Certificates generated (registry TLS, Docker TLS) if not already present, then trusted/used by their respective services

2. **Service Startup** (server-kube hosts)
   - Docker registry starts on `localhost:5000`
   - k3s initializes, waits for the registry certificate, starts Traefik
   - DNS entries (`registry.home`, `k3s.local`) added to `/etc/hosts`

3. **User Access**
   - Desktop environment loads (desktop hosts)
   - Profile-provided applications/IDEs available for use
   - Registry accessible via `registry.home`; Docker remote API (if enabled) via TLS on port 2376

## Performance Considerations

- **Memory limits** on Docker Registry (512M max, 400M high water mark)
- **CPU quotas** for resource fairness (200% for registry)
- **I/O weights** for disk priority management
- **Docker cleanup timers** (`server/docker/cleanup.nix`) prune build
  cache/images/volumes on a schedule so a long-running server doesn't
  silently fill its disk — see [Docker → Cleanup automation](./server/docker.md#cleanup-automation)

## Security Considerations

- Self-signed certificates for local use (registry + Docker TLS), not
  intended to be internet-facing
- Docker Registry itself has no authentication (internal only, bound to
  the k3s/host network)
- **Docker remote API** (`profiles/server-plain.nix` / `profiles/server-kube.nix`,
  `server/docker/`): TLS client-cert auth on port 2376, **not** plaintext
  port 2375. `server/docker/tls.nix` generates a CA + server + client cert
  pair under `/home/docker/certs/` on first boot — private keys never touch
  the Nix store or git. Copy `ca.pem`/`client-cert.pem`/`client-key.pem`
  from there to any machine you want to control the daemon from — see
  [Docker → TLS-secured remote API](./server/docker.md#tls-secured-remote-api)
  for the exact client setup.
- System-wide CA trust configuration for the registry certificate
- `development/common/tools/reset-jetbrains.nix` clears JetBrains
  evaluation-license state — see
  [JetBrains reset scripts](#jetbrains-reset-scripts) above; be aware of
  what it does before relying on it
