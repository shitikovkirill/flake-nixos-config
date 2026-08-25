{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    mcp-server-memory
    mcp-nixos
  ];

  home-manager.users.kirill = {
    home.file.".claude/.mcp.json".text = builtins.toJSON {
      mcpServers = {
        memory = {
          command = "${pkgs.mcp-server-memory}/bin/mcp-server-memory";
        };
        nixos = {
          command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
        };
      };
    };
  };
}
