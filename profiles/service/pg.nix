{ config, pkgs, ... }:
let
  domain = "db.home";
in
{
  imports = [
    ../../service/postgres
    ../../service/pgadmin
  ];

  services.devPostgres = {
    enable = true;
    users = [
      {
        user = "vtb";
        passwordFile = config.sops.secrets.postgres_vtb_password.path;
        database = "vtb";
      }
      {
        user = "photo_archiver";
        passwordFile = config.sops.secrets.postgres_photo_archiver_password.path;
        database = "photo_archiver";
      }
    ];
    authentication = [
      "host all all 192.168.88.0/24 md5"
    ];
  };

  services.pgadminService = {
    enable = true;
    inherit domain;
    email = "sh.kiruh@gmail.com";
    passwordFile = config.sops.secrets.pgadmin_password.path;
  };

  networking.hosts = {
    "127.0.0.1" = [ domain ];
  };
}
