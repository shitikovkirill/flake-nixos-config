{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    mcp-server-fetch
    playwright-mcp
  ];

  mcpServers = {
    fetch = {
      command = "${pkgs.mcp-server-fetch}/bin/mcp-server-fetch";
      disabled = true;
    };
    playwright = {
      command = "${pkgs.playwright-mcp}/bin/playwright-mcp";
      disabled = true;
    };
  };
}
