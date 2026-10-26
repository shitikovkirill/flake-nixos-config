# Quick Start

## Prerequisites

Enable experimental Nix features:

```bash
mkdir -p ~/.config/nix/
echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
```

## Building the System

Three `nixosConfigurations` are defined. `hosts/asus-n56vj/` has two roles
sharing the same hardware (`asus-n56vj-desktop`, a GUI workstation, and
`asus-n56vj-server`, headless docker/k3s); `hosts/asus-n580vn/` currently has
one (`asus-n580vn-desktop`). Build whichever one a given machine should
currently run as — this is a dry build, it doesn't touch the running system:

```bash
nix build .#nixosConfigurations.asus-n56vj-desktop.config.system.build.toplevel --no-link
# or asus-n56vj-server / asus-n580vn-desktop
```

## Applying Changes

Apply the system configuration:

```bash
sudo nixos-rebuild switch --flake .#asus-n56vj-desktop
# or asus-n56vj-server / asus-n580vn-desktop
```

## Next Steps

- See [Docker Registry](./server/docker-registry.md) for registry setup
- See [Architecture](./architecture.md) for a system overview
