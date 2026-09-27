====================
flake-nixos-config
====================

Welcome to the flake-nixos-config documentation!

A declarative NixOS configuration using Flakes with integrated Docker Registry,
Kubernetes (k3s), and comprehensive development tools.

.. toctree::
   :maxdepth: 2
   :caption: Getting Started

   quickstart

.. toctree::
   :maxdepth: 2
   :caption: Services & Components

   docker-registry
   architecture

.. toctree::
   :maxdepth: 2
   :caption: Development

   development

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

- :doc:`quickstart` - Get up and running
- :doc:`docker-registry` - Docker Registry setup and usage
- :doc:`architecture` - System architecture overview

Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
