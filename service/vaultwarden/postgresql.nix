{ config, lib, ... }:

with lib;
let
  cfg = config.services.vaultwardenService;
in
{
  config = mkIf cfg.enable {
    services.postgresql = {
      enable = true;
      ensureDatabases = [ "vaultwarden" ];
      ensureUsers = [
        {
          name = cfg.databaseUser;
          ensureDBOwnership = true;
        }
      ];
    };
  };
}
