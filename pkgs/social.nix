{ lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    telegram-desktop
    #slack
    #discord
    #zoom-us
    #skypeforlinux
    #teams
    #viber
  ];
}
