{ config, lib, pkgs, ... }:

{
  imports = [
    ./bash.nix
    ./git
    ./direnv
    ./nix
    ./h
    ./docker.nix
    ./ide.nix
    # ./electronics.nix
    # ./tools
    # ./python
    # ./go.nix
    # ./database
  ];
}

