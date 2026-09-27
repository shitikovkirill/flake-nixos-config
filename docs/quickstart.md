# Quick Start

## Prerequisites

Enable experimental Nix features:

```bash
mkdir -p ~/.config/nix/
echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
```

## Building the System

Build the NixOS configuration:

```bash
sudo nixos-rebuild build --flake .#asus-n56vj --impure
```

## Applying Changes

Apply the system configuration:

```bash
sudo nixos-rebuild switch --flake .#asus-n56vj --impure
```

## Next Steps

- See [Docker Registry](./docker-registry.md) for registry setup
- See project README for complete documentation
