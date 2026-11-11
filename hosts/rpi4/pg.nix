{ config, pkgs, ... }:
let
  domain = "db.rpi4";
in
{
  imports = [
    ../../service/postgres
  ];

  sops.secrets.vaultwarden_database_password = {
    # Re-run the password unit whenever the secret changes
    restartUnits = [ "set-user-password-in-db.service" ];
  };

  # Pi-specific PostgreSQL settings
  services.postgresql = {
    settings = {
      max_connections = 20;
      shared_buffers = "128MB";
      effective_cache_size = "512MB";
      work_mem = "4MB";
      maintenance_work_mem = "64MB";

      # Fewer, larger writes, which is gentler on SD cards
      wal_compression = "on";
      checkpoint_timeout = "15min";
      max_wal_size = "512MB";
      min_wal_size = "64MB";
    };
  };

  services.devPostgres = {
    enable = true;
    users = [
      {
        user = "vaultwarden";
        passwordFile = config.sops.secrets.vaultwarden_database_password.path;
        database = "vaultwarden";
      }
    ];
  };

  networking.hosts = {
    "127.0.0.1" = [ domain ];
  };
}
