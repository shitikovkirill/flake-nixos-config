{ config, pkgs, ... }:
let
  containersRm = pkgs.writeShellScriptBin ("containers_rm") ''
    CONTAINERS=$(nixos-container list)
    if [ -z "$CONTAINERS" ]
    then
        sudo rm -rf /var/lib/nixos-containers/* && sudo rm -rf /nix/var/nix/profiles/per-container/* && sudo rm -rf /nix/var/nix/gcroots/per-container/*
        echo "Container data cleared"
    else
        echo "You have activ container"
    fi
  '';
in {
  environment.systemPackages = with pkgs; [
    niv
    nox
    nix-info
    nix-index
    nixfmt-classic
    nix-prefetch-git
    containersRm
  ];

  environment.shellAliases = {
    nixfmt_this = "find . -print -name '*.nix' -exec nixfmt {} \\;";
  };
}
