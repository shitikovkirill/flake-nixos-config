====================
flake-nixos-config
====================

Welcome to the flake-nixos-config documentation!

A declarative NixOS configuration using Flakes with integrated Docker Registry,
Kubernetes (k3s), a standalone TLS-secured Docker profile, and profile-based
development tooling across three hosts.

.. toctree::
   :maxdepth: 2
   :caption: Getting Started

   pages/quickstart

.. toctree::
   :maxdepth: 2
   :caption: Services & Components

   pages/architecture
   pages/server/docker
   pages/server/docker-registry
   pages/server/ecs-anywhere
   pages/server/k8s

.. toctree::
   :maxdepth: 2
   :caption: Development

   pages/development/development
   pages/development/mcp-servers

Project Features
================

✅ **NixOS Declarative Configuration**
   Complete system configuration using Flakes, three hosts (``asus-n56vj-desktop``,
   ``asus-n56vj-server``, ``asus-n580vn-desktop``)

✅ **Docker Registry**
   Self-hosted registry with HTTPS support via Traefik or nginx

✅ **ECS Anywhere**
   Native (non-install-script) connection of NixOS hosts as external ECS container instances

✅ **Kubernetes Integration**
   k3s cluster management, mirrored through the local registry

✅ **Standalone Docker**
   TLS client-cert-authenticated remote API, no Kubernetes required

✅ **Profile-Based Development Environments**
   Python, Go, JS, Nix, databases (Postgres/MySQL/Redis/MongoDB), AI/MCP —
   each an opt-in ``profiles/*.nix`` a host lists explicitly

✅ **Desktop Environments**
   XFCE, KDE Plasma 5/6

✅ **Modular Organization**
   Clean separation of concerns; ``development/`` split by language,
   ``db/`` split by engine, nothing wired to a host implicitly

Project Structure
=================

.. code-block:: text

   hosts/                - Per-machine, per-role configs
   profiles/             - Named, opt-in package sets a host lists explicitly
   desktop/              - UI applications and desktop environments
   server/               - Docker, Kubernetes (k3s), registry, VPN
   development/          - Raw tool definitions, split by language (+ db/, common/)
   system/               - System configuration shared by every host
   docs/                 - Documentation

See :doc:`pages/architecture` for the full breakdown.

Quick Links
===========

- :doc:`pages/quickstart` - Get up and running
- :doc:`pages/architecture` - System architecture overview
- :doc:`pages/server/docker` - Standalone Docker + TLS remote API
- :doc:`pages/server/docker-registry` - Docker Registry setup and usage
- :doc:`pages/server/ecs-anywhere` - ECS Anywhere setup and usage
- :doc:`pages/server/k8s` - Kubernetes (k3s) setup
- :doc:`pages/development/development` - Development profiles

Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
