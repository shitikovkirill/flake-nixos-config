{ config, lib, pkgs, ... }:

{
  imports = [
    ./bash.nix
    ./git
    ./direnv
    ./nix
    ./h
    ./ide.nix
    #./tools
    #./docker.nix
    # ./python
    # ./go.nix
    #./database
    #./electronics.nix
  ];
}

