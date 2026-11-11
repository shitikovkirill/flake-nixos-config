{ config, lib, ... }:

with lib;
let
  cfg = config.services.vaultwardenService;
  db = cfg.database;
  scheme = if cfg.https then "https" else "http";
  usePostgres = db.backend == "postgresql";

  databaseUrl =
    if hasPrefix "/" db.host
    then "postgresql://${db.user}@/${db.name}?host=${db.host}"   # Unix socket
    else "postgresql://${db.user}@${db.host}/${db.name}";        # TCP (no password)
in
{
  config = mkIf cfg.enable {
    services.vaultwarden = {
      enable = true;
      dbBackend = db.backend;
      environmentFile = cfg.environmentFile;

      config = {
        DOMAIN = "${scheme}://${cfg.domain}";
        ROCKET_ADDRESS = cfg.address;
        ROCKET_PORT = cfg.port;
        ROCKET_LOG = "critical";

        SHOW_PASSWORD_HINT = false;
        INVITATIONS_ALLOWED = false;
        SIGNUPS_ALLOWED = false;
      }
      // optionalAttrs usePostgres {
        DATABASE_URL = databaseUrl;
        DATABASE_MAX_CONNS = 5;
      }
      // cfg.extraConfig;
    };

    # Wait for the database provided by the other service
    systemd.services.vaultwarden = mkIf usePostgres {
      after = db.dependsOn;
      requires = db.dependsOn;
    };
  };
}