# MCP Servers Organization Guide

This directory contains MCP (Model Context Protocol) server configurations organized by theme.

## Directory Structure

```
mcp/
├── default.nix   # Main module that imports and merges all MCP configs
├── core.nix      # Core/essential MCP servers
├── web.nix       # Web-related MCP servers
├── devops.nix    # DevOps and infrastructure MCP servers
├── ai.nix        # AI-related MCP servers
└── utils.nix     # Utility MCP servers
```

## How to Add New MCP Servers

When adding a new MCP server, follow these steps:

### 1. Determine the Category

Choose the appropriate file based on the server's purpose:

- **core.nix** - Essential, frequently-used servers
  - Examples: memory, time, filesystem
  - Criteria: Basic functionality needed in most sessions

- **web.nix** - Web scraping, fetching, browser automation
  - Examples: fetch, playwright, puppeteer
  - Criteria: Anything related to web interaction or HTTP

- **devops.nix** - Infrastructure, deployment, orchestration
  - Examples: kubernetes, docker, nixos, terraform
  - Criteria: System administration, cloud, CI/CD

- **ai.nix** - AI models, reasoning, processing
  - Examples: sequential-thinking, llm-tools
  - Criteria: AI/ML-specific functionality

- **utils.nix** - File conversion, formatting, general utilities
  - Examples: markitdown, pdf-converter, image-tools
  - Criteria: Standalone tools that don't fit other categories

### 2. Add to the Appropriate File

Edit the chosen category file and add:

1. The package to `environment.systemPackages`
2. The server configuration to `mcpServers`

Example:
```nix
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    existing-package
    new-mcp-server  # Add here
  ];

  mcpServers = {
    existing-server = {
      command = "${pkgs.existing-package}/bin/existing-package";
    };
    new-server = {  # Add here
      command = "${pkgs.new-mcp-server}/bin/new-mcp-server";
      disabled = true;  # Optional: disable by default
    };
  };
}
```

### 3. Enable/Disable Servers

- Set `disabled = true` for servers that should be installed but not active by default
- Omit the `disabled` field or set to `false` for active servers

### 4. Apply Changes

After adding a new MCP server:

```bash
# Rebuild your NixOS configuration
sudo nixos-rebuild switch --flake .

# The ~/.claude/.mcp.json file will be automatically updated
```

## Examples

### Adding a database MCP server

Since it's infrastructure-related, add to `devops.nix`:

```nix
environment.systemPackages = with pkgs; [
  mcp-postgres
];

mcpServers = {
  postgres = {
    command = "${pkgs.mcp-postgres}/bin/mcp-postgres";
  };
};
```

### Adding a file converter

Since it's a utility, add to `utils.nix`:

```nix
environment.systemPackages = with pkgs; [
  mcp-pdf-converter
];

mcpServers = {
  pdf-converter = {
    command = "${pkgs.mcp-pdf-converter}/bin/mcp-pdf-converter";
    disabled = true;
  };
};
```

## Notes

- The `default.nix` file automatically merges all configurations
- No need to modify `default.nix` when adding new servers to existing categories
- If you create a new category file, add it to the imports in `default.nix`
