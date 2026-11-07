{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.vaultwardenService;
in
{
  config = mkIf cfg.enable {
    systemd.services.vaultwarden = {
      description = "Vaultwarden password manager";
      after = [ "network.target" "postgresql.service" ];
      requires = [ "postgresql.service" ];
      wantedBy = [ "multi-user.target" ];

      environment = {
        DOMAIN = "http://${cfg.domain}";
        ROCKET_ADDRESS = "0.0.0.0";
        ROCKET_PORT = toString cfg.port;
        ROCKET_LOG = "critical";
        SHOW_PASSWORD_HINT = "false";
        INVITATIONS_ALLOWED = "false";
        SIGNUPS_ALLOWED = "false";
        LOG_FILE = "/var/log/vaultwarden.log";
      };

      script = ''
        ${if cfg.databasePasswordFile != null then ''
          PASSWORD=$(cat ${cfg.databasePasswordFile})
          export DATABASE_URL="postgresql://${cfg.databaseUser}:$PASSWORD@localhost/vaultwarden"
        '' else ''
          export DATABASE_URL="postgresql://${cfg.databaseUser}:${cfg.databasePassword}@localhost/vaultwarden"
        ''}
        exec ${pkgs.vaultwarden}/bin/vaultwarden
      '';

      serviceConfig = {
        Type = "simple";
        User = "vaultwarden";
        Group = "vaultwarden";
        Restart = "on-failure";
        RestartSec = 10;
        WorkingDirectory = "/var/lib/vaultwarden";
        StateDirectory = "vaultwarden";
        LogsDirectory = "vaultwarden";
        PrivateTmp = true;
        NoNewPrivileges = true;
      };
    };
  };
}
