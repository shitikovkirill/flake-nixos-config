{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    markitdown-mcp
  ];

  mcpServers = {
    markitdown = {
      command = "${pkgs.markitdown-mcp}/bin/markitdown-mcp";
      disabled = true;
    };
  };
}
