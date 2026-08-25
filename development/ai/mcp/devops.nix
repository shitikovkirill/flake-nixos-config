{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    mcp-k8s-go
    mcp-nixos
  ];

  mcpServers = {
    k8s = {
      command = "${pkgs.mcp-k8s-go}/bin/mcp-k8s-go";
      disabled = true;
    };
    nixos = {
      command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
      disabled = true;
    };
  };
}
