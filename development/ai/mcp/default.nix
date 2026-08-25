{ config, pkgs, lib, ... }:

let
  # Define all MCP servers configurations
  mcpServers = {
    # Core
    memory = {
      command = "${pkgs.mcp-server-memory}/bin/mcp-server-memory";
    };
    time = {
      command = "${pkgs.mcp-server-time}/bin/mcp-server-time";
    };

    # Web
    fetch = {
      command = "${pkgs.mcp-server-fetch}/bin/mcp-server-fetch";
      disabled = true;
    };
    playwright = {
      command = "${pkgs.playwright-mcp}/bin/playwright-mcp";
      disabled = true;
    };

    # DevOps
    k8s = {
      command = "${pkgs.mcp-k8s-go}/bin/mcp-k8s-go";
      disabled = true;
    };
    nixos = {
      command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
      disabled = true;
    };

    # AI
    "sequential-thinking" = {
      command = "${pkgs.mcp-server-sequential-thinking}/bin/mcp-server-sequential-thinking";
      disabled = true;
    };

    # Utils
    markitdown = {
      command = "${pkgs.markitdown-mcp}/bin/markitdown-mcp";
      disabled = true;
    };

    # Language Servers
    "language-server" = {
      command = "${pkgs.mcp-language-server}/bin/mcp-language-server";
      args = [
        "--language-server"
        "${pkgs.pyright}/bin/pyright-langserver"
        "--stdio"
      ];
    };
  };
in
{
  environment.systemPackages = with pkgs; [
    # Core
    mcp-server-memory
    mcp-server-time

    # Web
    mcp-server-fetch
    playwright-mcp

    # DevOps
    mcp-k8s-go
    mcp-nixos

    # AI
    mcp-server-sequential-thinking

    # Utils
    markitdown-mcp

    # Language Servers
    mcp-language-server
    pyright
  ];

  home-manager.users.kirill = {
    home.file.".config/mcp/config.json".text = builtins.toJSON {
      inherit mcpServers;
    };
  };
}
