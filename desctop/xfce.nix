{ config, pkgs, lib, ... }:
{
  services.xserver = {
    enable = true;
    desktopManager.xfce.enable = true;
    videoDrivers = [ "nvidia" ];
  };
  services.displayManager.defaultSession = "xfce";
}