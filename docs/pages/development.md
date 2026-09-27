# Development Environment

## Overview

The development environment includes tools for:
- Python development
- Nix configuration
- Database work
- AI/ML tools (MCP)
- Git version control

## Available Tools

### Python
- Python development environments
- Virtual environments support
- Package management tools

### Nix
- Nix language tooling
- Flake support
- nixpkgs integration
- Home-manager configuration

### Database
- Database clients and CLI tools
- Connection utilities
- Data migration tools

### AI/ML
- MCP (Machine Learning Protocol) tools
- AI development frameworks
- LLM integration tools

### Git
- Git configuration
- Git utilities and hooks
- Version control helpers

### VS Code Remote Server

`development/vs_code/` provides VS Code Remote-SSH server support via the
[`nixos-vscode-server`](https://github.com/nix-community/nixos-vscode-server)
community module. It's disabled by default — uncomment `./vs_code` in
`development/default.nix` to enable it on a given host.

Once enabled, if the remote server needs a manual restart/fix:

```bash
systemctl --user enable auto-fix-vscode-server.service
systemctl --user start auto-fix-vscode-server.service
```

## Setting Up Development Environment

### Using Nix Flakes

Enter a development shell:
```bash
nix flake enter .#dev
```

### Python Development

Create a Python environment:
```bash
nix develop .#python
```

### Nix Development

Work with NixOS configuration:
```bash
nix develop .#nix
```

## Workflow

1. **Clone repository**
   ```bash
   git clone <repo-url>
   cd flake-nixos-config
   ```

2. **Enter development environment**
   ```bash
   nix develop
   ```

3. **Make changes**
   - Edit Nix files
   - Test configurations
   - Run development tools

4. **Build and test**
   ```bash
   sudo nixos-rebuild build --flake .#asus-n56vj-desktop
   # or .#asus-n56vj-server
   ```

5. **Apply changes**
   ```bash
   sudo nixos-rebuild switch --flake .#asus-n56vj-desktop
   # or .#asus-n56vj-server
   ```

## Development Tools

### Configuration Management
- Nix language and flakes
- Home-manager for user configuration
- NixOS modules system

### Version Control
- Git with custom hooks
- GitHub integration
- Branch management tools

### Code Quality
- Linters and formatters
- Type checkers
- Test runners

## Best Practices

1. **Use flakes for reproducibility**
   - Pin versions explicitly
   - Use lockfiles
   - Test in isolation

2. **Keep configurations modular**
   - One concern per module
   - Clear dependencies
   - Easy to compose

3. **Document your changes**
   - Update docs with new features
   - Add comments for complex logic
   - Keep README updated

4. **Test before deployment**
   - Build in a sandbox
   - Verify changes
   - Check dependencies

## Troubleshooting

### Flake issues
```bash
# Update flake.lock
nix flake update

# Check flake
nix flake check
```

### Build failures
```bash
# Clean build
nix-store --gc
sudo nixos-rebuild build --flake .#asus-n56vj-desktop
```

### Environment issues
```bash
# Recreate shell
nix flake repl .
```

## Resources

- [Nix Manual](https://nixos.org/manual/nix/)
- [NixOS Manual](https://nixos.org/manual/nixos/)
- [Flakes Documentation](https://nixos.wiki/wiki/Flakes)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
