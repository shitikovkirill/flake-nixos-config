{ config, lib, ... }:

with lib;
let
  cfg = config.services.vaultwardenService;
in
{
  config = mkIf cfg.enable {
    users.users.vaultwarden = {
      isSystemUser = true;
      group = "vaultwarden";
      home = "/var/lib/vaultwarden";
      createHome = true;
    };

    users.groups.vaultwarden = { };
  };
}
