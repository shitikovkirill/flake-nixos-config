{
  config,
  pkgs,
  lib,
  ...
}:

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
    };
    playwright = {
      command = "${pkgs.playwright-mcp}/bin/playwright-mcp";
    };

    # DevOps
    k8s = {
      command = "${pkgs.mcp-k8s-go}/bin/mcp-k8s-go";
    };
    nixos = {
      command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
    };

    # AI
    "sequential-thinking" = {
      command = "${pkgs.mcp-server-sequential-thinking}/bin/mcp-server-sequential-thinking";
    };

    # Utils
    markitdown = {
      command = "${pkgs.markitdown-mcp}/bin/markitdown-mcp";
    };

    # Language Servers
    "language-server" = {
      command = "${pkgs.mcp-language-server}/bin/mcp-language-server";
      args = [
        "--lsp"
        "${pkgs.pyright}/bin/pyright-langserver"
        "--workspace"
        "\${LSP_WORKSPACE}"
        "--"
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
