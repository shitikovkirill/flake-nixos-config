{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    mcp-server-sequential-thinking
  ];

  mcpServers = {
    "sequential-thinking" = {
      command = "${pkgs.mcp-server-sequential-thinking}/bin/mcp-server-sequential-thinking";
      disabled = true;
    };
  };
}
