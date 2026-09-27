
# Building Documentation

This directory contains the Sphinx documentation for flake-nixos-config.

## Using Nix to Build

### Build with Nix (Recommended)

Build the complete documentation:

```bash
nix build .
```

The compiled HTML documentation will be available in the `result/` directory.

### Development Shell with Nix

Enter a development environment with all necessary tools:

```bash
nix develop
```

Once inside the shell, you can use the Makefile commands:

```bash
cd docs
make html        # Build HTML documentation
make clean       # Clean build artifacts
make pdf         # Build PDF documentation
make epub        # Build ePub documentation
```

## Local Build (Without Nix)

### Prerequisites

Install Sphinx and required dependencies:

```bash
pip install sphinx sphinx-rtd-theme myst-parser furo
```

### Build Commands

```bash
cd docs
make html
```

The built documentation will be in `_build/html/`.

## Documentation Structure

```
docs/
├── conf.py              # Sphinx configuration
├── index.rst            # Master document
├── Makefile             # Build automation
├── flake.nix            # Nix flake for reproducible builds
├── pages/               # Documentation sources
│   ├── quickstart.md    # Getting started guide
│   ├── architecture.md  # System architecture
│   ├── development.md   # Development setup
│   ├── docker-registry.md  # Docker registry guide
│   └── README.md        # Documentation overview
└── _build/              # Build artifacts (generated)
    └── html/            # Compiled HTML
```

## Configuration

### Theme

The documentation uses the **Furo** theme with dark mode support.

### Markdown Support

MyST parser is configured to support:
- Colon fences (code blocks with :::)
- Task lists
- Definition lists

### Supported Formats

- HTML (default)
- PDF
- ePub
- Plain text
- man pages

## Viewing Documentation

After building, open the documentation in your browser:

```bash
# If built with Nix:
open result/index.html

# If built locally:
open _build/html/index.html
```

## Adding New Pages

1. Create a `.md` file in `pages/`
2. Add it to the toctree in `index.rst`:

```rst
.. toctree::
   :maxdepth: 2
   :caption: Section Name

   pages/your-page
```

3. Rebuild the documentation

## Troubleshooting

### Clean Build

Remove all build artifacts:

```bash
make clean
```

Then rebuild:

```bash
make html
```

### Flake Lock Issues

If you get flake lock issues:

```bash
nix flake update
```

### Module Not Found

Ensure you're in the development shell:

```bash
nix develop
make html
```

## Dependencies

- Python 3.13+
- Sphinx 9.1+
- MyST Parser 5.0+
- Furo theme
- Sphinx RTD Theme

All dependencies are automatically managed by Nix.

## Password-Protected Nginx Page on NixOS

This is a general recipe for putting an `nginx` site behind HTTP Basic Auth
on a NixOS server — for example if you want to publish this documentation's
`result/` output but keep it private.

### 1. Generate a htpasswd file

Generate the credentials file outside the Nix store (e.g. in `/var/lib/nginx-auth/`)
so the password hash is not world-readable via `/nix/store`:

```bash
sudo mkdir -p /var/lib/nginx-auth
nix-shell -p apacheHttpd --run \
  "sudo htpasswd -c -B /var/lib/nginx-auth/.htpasswd myuser"
```

Drop `-c` when adding additional users to an existing file.

### 2. Reference the docs flake instead of a standalone derivation

`docs/flake.nix` already builds this exact site as `packages.x86_64-linux.default`,
with its Sphinx dependencies declared once. Add `docs/` as a flake input of
the system flake instead of writing a second derivation that duplicates
`sphinx`/`myst-parser`/`furo`/... in a separate `.nix` file:

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = { ... };
    docs = {
      url = "path:./docs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, docs, ... }@inputs: {
    nixosConfigurations.asus-n56vj-server = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; }; # makes `inputs` available to modules
      modules = [ /* ... */ ];
    };
  };
}
```

`inputs.nixpkgs.follows = "nixpkgs"` keeps the docs flake pinned to the same
nixpkgs as the rest of the system instead of fetching its own copy.

Then in the nginx module, reference `inputs.docs.packages.${pkgs.system}.default`
directly as `root`. It's a Nix store path, which is world-readable, so nginx
can serve it with no extra copy step, and the content is always exactly what
`docs/flake.nix` last built:

```nix
{ config, pkgs, inputs, ... }:
{
  services.nginx.virtualHosts."docs.home" = {
    forceSSL = true;
    sslCertificate = "/var/lib/registry-certs/registry.home.crt"; # or your own cert
    sslCertificateKey = "/var/lib/registry-certs/registry.home.key";

    locations."/" = {
      root = inputs.docs.packages.${pkgs.system}.default;
      extraConfig = ''
        auth_basic "Restricted";
        auth_basic_user_file /var/lib/nginx-auth/.htpasswd;
      '';
    };
  };
}
```

Rebuilding the system (`nixos-rebuild switch`) re-evaluates the `docs` input
and points nginx at the new store path automatically whenever the docs
sources change — no manual copy, no stale files, and only one place
(`docs/flake.nix`) declares the build's dependencies.


### 3. Apply and test

```bash
sudo nixos-rebuild switch --flake .#asus-n56vj-server
curl -u myuser -I https://docs.home/
```

A `401 Unauthorized` without credentials and `200 OK` with the correct
username/password confirms Basic Auth is working.

### Notes

- `htpasswd -B` uses bcrypt; nginx on NixOS supports bcrypt, MD5 (`apr1`),
  and SHA1 hashes in the auth file.
- Keep the `.htpasswd` file outside of any Nix-tracked source directory —
  files copied into the store via `pkgs.writeText`/`./path` become world
  readable at `/nix/store/...`, defeating the point of the password.
- To protect only part of a site, scope `auth_basic`/`auth_basic_user_file`
  to a specific `locations."/subpath"` block instead of `"/"`.
