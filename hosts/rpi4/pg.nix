{ config, pkgs, ... }:
let
  domain = "db.rpi4";
in
{
  imports = [
    ../../service/postgres
  ];

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
