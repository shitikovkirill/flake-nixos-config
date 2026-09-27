# Quick Start

## Prerequisites

Enable experimental Nix features:

```bash
mkdir -p ~/.config/nix/
echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
```

## Building the System

This machine has two host profiles sharing the same hardware
(`hosts/asus-n56vj/`): `asus-n56vj-desktop` (GUI workstation) and
`asus-n56vj-server` (headless, docker/k3s services). Build whichever one
this machine should currently run as:

```bash
sudo nixos-rebuild build --flake .#asus-n56vj-desktop
# or
sudo nixos-rebuild build --flake .#asus-n56vj-server
```

## Applying Changes

Apply the system configuration:

```bash
sudo nixos-rebuild switch --flake .#asus-n56vj-desktop
# or
sudo nixos-rebuild switch --flake .#asus-n56vj-server
```

## Next Steps

- See [Docker Registry](./docker-registry.md) for registry setup
- See [Architecture](./architecture.md) for a system overview
