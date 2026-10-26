{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    nodejs
    yarn
    pnpm
    typescript
  ];

  programs.zsh.ohMyZsh.plugins = [ "node" "npm" ];

  environment.shellAliases = {
    npm-clean = "rm -rf node_modules package-lock.json && npm install";
  };
}
