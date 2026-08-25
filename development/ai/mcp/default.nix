{ config, pkgs, lib, ... }:

let
  # Import all MCP module configurations
  coreModule = import ./core.nix { inherit config pkgs; };
  webModule = import ./web.nix { inherit config pkgs; };
  devopsModule = import ./devops.nix { inherit config pkgs; };
  aiModule = import ./ai.nix { inherit config pkgs; };
  utilsModule = import ./utils.nix { inherit config pkgs; };
  languageServersModule = import ./language-servers.nix { inherit config pkgs; };

  # Merge all MCP servers configurations
  allMcpServers = lib.mkMerge [
    coreModule.mcpServers
    webModule.mcpServers
    devopsModule.mcpServers
    aiModule.mcpServers
    utilsModule.mcpServers
    languageServersModule.mcpServers
  ];

  # Merge all package lists
  allPackages =
    coreModule.environment.systemPackages ++
    webModule.environment.systemPackages ++
    devopsModule.environment.systemPackages ++
    aiModule.environment.systemPackages ++
    utilsModule.environment.systemPackages ++
    languageServersModule.environment.systemPackages;
in
{
  imports = [
    ./core.nix
    ./web.nix
    ./devops.nix
    ./ai.nix
    ./utils.nix
    ./language-servers.nix
  ];

  home-manager.users.kirill = {
    home.file.".claude/.mcp.json".text = builtins.toJSON {
      mcpServers = allMcpServers;
    };
  };
}
