{ config, ... }:

let
  userName = "kirill";
  home = "/home/${userName}";
  dataRoot = "/ssd/syncthing";
in
{
  imports = [ ../../service/syncthing ];

  services.syncthingService = {
    enable = true;
    dataDir = "/ssd/syncthing";             # synced folders
    databaseDir = "/ssd/syncthing-db";      # index database
    # configDir stays on the SD card (small, rarely written)
  };
}
