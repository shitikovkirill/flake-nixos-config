====================
flake-nixos-config
====================

Welcome to the flake-nixos-config documentation!

A declarative NixOS configuration using Flakes with integrated Docker Registry,
Kubernetes (k3s), and comprehensive development tools.

.. toctree::
   :maxdepth: 2
   :caption: Getting Started

   pages/quickstart

.. toctree::
   :maxdepth: 2
   :caption: Services & Components

   pages/docker-registry
   pages/architecture

.. toctree::
   :maxdepth: 2
   :caption: Development

   pages/development

Project Features
================

✅ **NixOS Declarative Configuration**
   Complete system configuration using Flakes

✅ **Docker Registry**
   Self-hosted registry with HTTPS support via Traefik

✅ **Kubernetes Integration**
   k3s cluster management

✅ **Development Environments**
   Python, Nix, AI/ML, database tools

✅ **Desktop Environments**
   XFCE, KDE Plasma 5/6

✅ **Modular Organization**
   Clean separation of concerns

Project Structure
=================

.. code-block:: text

   desktop/              - UI applications and desktop environments
   server/               - Server applications and utilities
   development/          - Development tools and environments
   system/               - System configuration
   docs/                 - Documentation

Quick Links
===========

- :doc:`pages/quickstart` - Get up and running
- :doc:`pages/docker-registry` - Docker Registry setup and usage
- :doc:`pages/architecture` - System architecture overview

Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
