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
