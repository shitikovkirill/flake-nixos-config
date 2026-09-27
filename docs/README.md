# Documentation

Welcome to the flake-nixos-config documentation!

## Table of Contents

### Getting Started
- [Quick Start](./quickstart.md) - Setup and build instructions

### Services & Components
- [Docker Registry](./docker-registry.md) - Self-hosted Docker registry with Traefik integration

### Project Structure
```
desktop/              - UI applications and desktop environments
server/               - Server applications and utilities
development/          - Development tools and environments
system/               - System configuration
docs/                 - Documentation (this folder)
```

## Architecture Overview

**Desktop Applications**
- XFCE, KDE Plasma 5/6 desktop environments
- Browser, media, social media, games, torrent applications

**Server Components**
- Docker Registry with HTTPS support via Traefik
- Kubernetes (k3s) integration
- Docker daemon configuration
- VPN and utility packages

**Development**
- AI/ML tools (MCP)
- Database tools
- Python/Nix development environments
- Git utilities

## System Features

- ✅ NixOS declarative configuration using Flakes
- ✅ Docker Registry with self-signed TLS certificates
- ✅ Kubernetes (k3s) integration
- ✅ Traefik reverse proxy for HTTPS
- ✅ Development environment management
- ✅ Modular, organized structure

## Getting Help

For detailed information on specific components, see the relevant documentation in this folder.
