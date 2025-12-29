{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ bruno postman xmind ];

  imports = [ ./jetbrains.nix ];
}
