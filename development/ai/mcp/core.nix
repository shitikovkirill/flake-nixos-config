{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    mcp-server-memory
    mcp-server-time
  ];

  mcpServers = {
    memory = {
      command = "${pkgs.mcp-server-memory}/bin/mcp-server-memory";
    };
    time = {
      command = "${pkgs.mcp-server-time}/bin/mcp-server-time";
    };
  };
}
