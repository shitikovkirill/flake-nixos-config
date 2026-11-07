{ config, ... }:

let
  userName = "kirill";
  home = "/home/${userName}";
  dataRoot = "/ssd/syncthing";
in
{
  imports = [ ../../service/syncthing ];

  # Start Syncthing only when the external disk is mounted.
  systemd.services.syncthing.unitConfig.RequiresMountsFor = [ "/ssd" ];

  services.syncthingService = {
    enable = true;
    user = userName;
    group = "users";
    dataDir = dataRoot;
    configDir = "${home}/.config/syncthing";
    openDefaultPorts = true;
    guiAddress = "127.0.0.1:8384";
  };
}
