{ config, ... }:

let
  userName = "kirill";
  home = "/home/${userName}";
  dataRoot = "/ssd/syncthing";
in
{
  imports = [ ../../service/syncthing ];

  services.caddy = {
    enable = true;
    virtualHosts."sync.home".extraConfig = ''
      tls internal
      reverse_proxy 127.0.0.1:8384 {
        header_up Host {upstream_hostport}
      }
    '';
  };

  services.syncthingService = {
    enable = true;
    dataDir = "/ssd/syncthing/data";             # synced folders
    databaseDir = "/ssd/syncthing/db";      # index database
    # configDir stays on the SD card (small, rarely written)
  };
}
