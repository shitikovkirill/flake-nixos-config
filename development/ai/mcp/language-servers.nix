{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    mcp-language-server
    pyright
  ];

  mcpServers = {
    "language-server" = {
      command = "${pkgs.mcp-language-server}/bin/mcp-language-server";
      args = [
        "--language-server"
        "${pkgs.pyright}/bin/pyright-langserver"
        "--stdio"
      ];
    };
  };
}
