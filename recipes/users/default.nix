{ config, pkgs, lib, ... }:
with lib;
let
  motd = with config; ''
    Welcome to ${networking.hostName}

    - This machine is managed by NixOS

    OS:      NixOS ${system.nixos.release} (${system.nixos.codeName})
    Version: ${system.nixos.version}
    Kernel:  ${boot.kernelPackages.kernel.version}
  '';
in {
  users = {
    mutableUsers = false;
    inherit motd;
  };
}
