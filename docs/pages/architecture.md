# System Architecture

## Overview

flake-nixos-config is a declarative NixOS system configuration that combines:
- Desktop environments and applications
- Server services and utilities
- Development tools and environments
- System-wide configuration management

## Directory Structure

```
flake-nixos-config/
├── desktop/                    # UI applications
│   ├── environments/           # xfce, plasma5, plasma6
│   ├── apps/                   # browser, games, media, social, torrents
│   └── default.nix
├── server/                     # Server applications
│   ├── docker/                 # Docker daemon config
│   ├── docker-registry/        # Self-hosted Docker registry
│   ├── k8s/                    # Kubernetes (k3s)
│   ├── pkgs/                   # VPN and utilities
│   └── default.nix
├── development/                # Development tools
│   ├── ai/                     # AI/ML tools (MCP)
│   ├── database/               # Database tools
│   ├── git/                    # Git utilities
│   ├── python/                 # Python environments
│   └── ...
├── system/                     # System configuration
│   ├── data/                   # Data directories
│   └── users/                  # User configuration
├── docs/                       # Documentation (Sphinx)
├── flake.nix                   # Flake configuration
└── README.md                   # Root documentation
```

## Component Architecture

### Desktop Layer
- **Environments**: Multiple desktop environments (XFCE, KDE Plasma)
- **Applications**: User-facing applications (browser, media, games)
- **Features**: GUI applications, user preferences, theming

### Server Layer
- **Docker Registry**: Self-hosted container image registry
- **Kubernetes**: k3s cluster for orchestration
- **Docker**: Container runtime
- **Utilities**: VPN, system utilities

### Development Layer
- **AI/ML**: Machine Learning tools, MCP integration
- **Database**: Database clients and tools
- **Languages**: Python, Nix environments
- **Version Control**: Git configuration and tools

### System Layer
- **Users**: User accounts and permissions
- **Data**: System data directories
- **Configuration**: Global system settings

## Service Integration

### Docker Registry

```
┌─────────────────────┐
│  Docker Client      │
└──────────┬──────────┘
           │ HTTPS
           ▼
┌─────────────────────┐
│ Traefik (k3s)       │
│ - TLS Termination   │
│ - Route Host        │
└──────────┬──────────┘
           │ HTTP
           ▼
┌─────────────────────┐
│ Docker Registry     │
│ - Port 5000         │
│ - /home/docker-     │
│   registry/data     │
└─────────────────────┘
```

### Kubernetes Integration

- k3s provides lightweight Kubernetes
- Traefik serves as ingress controller
- Services integrate with system DNS
- Persistent volumes use host paths

## Certificate Management

- Self-signed certificates generated during build
- SANs (Subject Alternative Names) for proper TLS validation
- Automatic trust via NixOS security.pki
- Regeneration via systemd services

## Configuration Management

All configuration is declarative using:
- **Nix language** for configuration as code
- **Flakes** for reproducible, versioned environments
- **Modular structure** for easy composition
- **systemd** for service management

## Dependencies

### Build-time
- Nix package manager with flakes support
- openssl for certificate generation

### Runtime
- NixOS operating system
- systemd for service management
- k3s for Kubernetes features
- Docker for container runtime

## How It All Works Together

1. **System Boot**
   - NixOS evaluates flake.nix
   - Services start in dependency order
   - Certificates generated and trusted

2. **Service Startup**
   - Docker registry starts on localhost:5000
   - k3s initializes and starts Traefik
   - DNS entries added to /etc/hosts

3. **User Access**
   - Desktop environment loads
   - Applications available for use
   - Registry accessible via registry.home

## Performance Considerations

- **Memory limits** on Docker Registry (512M max, 400M high water mark)
- **CPU quotas** for resource fairness (200% for registry)
- **I/O weights** for disk priority management
- **Network optimization** via Traefik configuration

## Security Considerations

- Self-signed certificates for local use
- No authentication on registry (internal only)
- All services bound to localhost or private networks
- System-wide CA trust configuration
