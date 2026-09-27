
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
