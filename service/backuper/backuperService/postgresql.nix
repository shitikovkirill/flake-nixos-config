{ config, lib, ... }:
let
  cfg = config.services.backuperService;
in
{
  config = lib.mkIf (cfg.enable && cfg.postgresql.enable) {
    services.postgresqlBackup = {
      enable = true;
      location = cfg.postgresql.location;
      databases = cfg.databases;
      backupAll = cfg.databases == [ ];
      compression = "gzip";
      startAt = [ ];
    };
  };
}
