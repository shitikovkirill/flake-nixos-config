# Development Environment

## Overview

Development tooling is split into **profiles** — named, opt-in package sets
under `profiles/`. Each one imports raw content from `development/` (or
`server/` for the two server profiles) and installs
`environment.systemPackages`, zsh plugins, and shell aliases for one
concern. A host gets a profile only by listing it explicitly in its
`nixosConfigurations` entry in `flake.nix` — nothing under `development/`
is wired to any host implicitly.

This replaced an earlier `development/default.nix` that unconditionally
imported (or half-commented-out) a fixed list of tools for every host. That
made it impossible to give one host Go tooling and another JS tooling
without editing a shared file both of them used.

## `development/` is organized by language

Inside `development/`, content is split one directory per programming
language (`python/`, `go/`, `js/`, `nix/`) plus `db/` (split further per
database engine — see below) and `common/` for everything that isn't
specific to a single language: git, direnv, bash, VS Code, AI/MCP tooling,
the dev-network `/etc/hosts` setup, electronics, and the JetBrains
trial-reset helper. The rule is simple: **if a tool is specific to one
language, it lives under that language's directory; if it isn't, it goes
in `common/`.**

Each language directory that has a JetBrains IDE also has its own `ide/`
subdirectory (`python/ide/`, `go/ide/`, `js/ide/`) holding that IDE plus its
reset script, so the language's full toolchain — runtime, CLI, and IDE —
lives together.

```
development/
├── common/            # not specific to any one language
│   ├── ai/               # MCP servers for Claude Code — see mcp-servers.md
│   ├── bash.nix
│   ├── direnv/
│   ├── electronics.nix   # arduino, rpi-imager
│   ├── git/
│   ├── h/                # directory-jump tool
│   ├── ide/
│   │   ├── client.nix     # VS Code
│   │   └── server/        # VS Code Remote-SSH server support
│   ├── network/          # private /etc/hosts entries, dev firewall ports
│   ├── nix-ld.nix        # run dynamically-linked non-NixOS binaries
│   └── tools/
│       ├── reset-jetbrains.nix
│       └── shell.nix
├── db/                 # split per engine — see "Databases" below
├── go/
│   ├── default.nix       # go compiler/toolchain
│   └── ide/               # GoLand + reset script
├── js/
│   ├── default.nix       # nodejs, yarn, pnpm, typescript, npm-clean alias
│   └── ide/               # WebStorm + reset script
├── nix/
│   └── default.nix       # niv, nox, nix-index, nixfmt, nix-prefetch-git, containers_rm, nixfmt_this alias
└── python/
    ├── default.nix       # python3, poetry, uv, ruff, ipython, pipx, py-clean/ppath aliases
    ├── ide/                # PyCharm + reset script
    ├── modules/            # legacy standalone package derivations (create-aio-app, setuptools-scm-git-archive)
    └── nix-shell/          # standalone nix-shell entrypoint for the above, not wired to any profile
```

## Profiles

| Profile | Imports | Contents |
|---|---|---|
| `minimal-dev` | `development/common/{bash.nix,git,direnv,h,ide/client.nix,ai,network,nix-ld.nix}` | Baseline: shellcheck+bash history, full `programs.git` config (git, gitg, git-crypt, pre-commit), direnv+nix-direnv, `h` directory-jump, VS Code, MCP/AI tooling, private dev `/etc/hosts` + firewall port range, `nix-ld` for running dynamically-linked non-NixOS binaries |
| `nix-dev` | `development/nix` | niv, nox, nix-info, nix-index, nixfmt, nix-prefetch-git, a `containers_rm` helper, `nixfmt_this` alias |
| `python-dev` | `development/python` + `development/python/ide` | python3, poetry, uv, ruff, ipython, pipx, `py-clean`/`ppath` aliases, PyCharm + trial-reset script |
| `go-dev` | `development/go` + `development/go/ide` | go, GoLand + trial-reset script |
| `js-dev` | `development/js` + `development/js/ide` | nodejs, yarn, pnpm, typescript, `npm-clean` alias, WebStorm + trial-reset script |
| `db-dev` | `development/db/*` | See [Databases](#databases) below |
| `ide-tools` | — (inline) | Cross-tool leftovers that don't fit one language: bruno, postman, xmind, RubyMine + PhpStorm trial-reset scripts |
| `electronics-dev` | `development/common/electronics.nix` | arduino, rpi-imager — not currently used by any host |
| `server-kube` | `server/k8s` + `server/docker-registry` | See [Kubernetes](../server/k8s.md) |
| `server-plain` | `server/docker` | See [Docker](../server/docker.md) |

### How a host picks its profiles

Each host has its own `hosts/<name>/profiles.nix` listing every profile
above as an import, all commented out except `minimal-dev`:

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

To turn a profile on for a host, uncomment its line in that host's
`profiles.nix` — nothing in `flake.nix` needs to change, and it can't
accidentally affect another host. `server-kube`/`server-plain` are wired
directly per role in `flake.nix` instead (they define what a *role* is —
"headless docker/k3s box" — not a personal tool preference), though
`asus-n580vn-desktop` adds `server-plain` directly even on its desktop
role, showing that's a default rather than a hard rule. See
[Architecture → Hosts and role variants](../architecture.md#hosts-and-role-variants)
for the full per-host table.

## Databases

`development/db/` splits database tooling the same way the top-level
`development/` splits languages — one directory per engine, with anything
not specific to one engine at the `db/` top level instead:

| Directory | Contents |
|---|---|
| `db/ide/` | DBeaver + JetBrains DataGrip — both work across Postgres/MySQL/etc. in one product, so neither belongs to a single engine below |
| `db/postgres/` | `postgresql` (CLI: `psql`) |
| `db/mysql/` | `mariadb` (CLI: `mysql`) — nixpkgs has no client-only attribute, so this is the full server+client package |
| `db/redis/` | `redis` (CLI: `redis-cli`) |
| `db/redis/ide/` | RedisInsight — Redis-specific GUI, so it's under `redis/` rather than `db/ide/` |
| `db/mongo/` | `mongosh` (official CLI shell) |
| `db/mongo/ide/` | MongoDB Compass + Robo 3T — Mongo-specific GUIs |

`profiles/db-dev.nix` imports all of the above in one go; there's no
per-engine profile split (unlike languages) since database access tends to
be needed all-at-once rather than one engine at a time.

## JetBrains trial-reset scripts

Several profiles above include a generated `reset-<IDE>` binary
(`development/common/tools/reset-jetbrains.nix`) that clears a JetBrains
IDE's evaluation-license state. It predates this repo's current form and is
carried forward as-is; be aware of what it does before relying on it.

## VS Code Remote Server

`development/common/ide/server/` provides VS Code Remote-SSH server support
via the
[`nixos-vscode-server`](https://github.com/nix-community/nixos-vscode-server)
community module. It's not part of any profile — it's added directly in
`flake.nix` on hosts that need it (currently `asus-n56vj-server`).

Once enabled, if the remote server needs a manual restart/fix:

```bash
systemctl --user enable auto-fix-vscode-server.service
systemctl --user start auto-fix-vscode-server.service
```

## Adding a new profile

1. Put the raw tool definition under `development/<language>/default.nix`
   (or `development/common/<name>` if it isn't language-specific). Just
   `environment.systemPackages` and whatever `programs.*`/aliases it needs —
   no host-specific logic here.
2. If it has a JetBrains (or other) IDE, put that under
   `development/<language>/ide/default.nix`, importing
   `../../common/tools/reset-jetbrains.nix` if it needs a trial-reset script.
3. Add `profiles/<name>.nix` that imports the directory (and its `ide/` if
   any).
4. Add a commented `# ../../profiles/<name>.nix` line to every
   `hosts/<name>/profiles.nix` (so it shows up as an available toggle
   everywhere), and uncomment it on whichever host(s) should actually have
   it active.
5. `nix build .#nixosConfigurations.<host>.config.system.build.toplevel
   --no-link` to check it evaluates before switching.

## Building and Applying

```bash
# Dry-build only (safe, doesn't touch the running system)
nix build .#nixosConfigurations.<host>.config.system.build.toplevel --no-link

# Build + activate on next boot
sudo nixos-rebuild build --flake .#<host>

# Build + activate now
sudo nixos-rebuild switch --flake .#<host>
```

Current `<host>` values: `asus-n56vj-desktop`, `asus-n56vj-server`,
`asus-n580vn-desktop`.

## Troubleshooting

### Flake issues

```bash
nix flake update
nix flake check
```

### Build failures

```bash
nix-store --gc
sudo nixos-rebuild build --flake .#<host>
```

## Resources

- [Nix Manual](https://nixos.org/manual/nix/)
- [NixOS Manual](https://nixos.org/manual/nixos/)
- [Flakes Documentation](https://nixos.wiki/wiki/Flakes)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
