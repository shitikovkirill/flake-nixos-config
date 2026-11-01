{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.devPostgres;
in
{

  options = {
    services.devPostgres = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = ''
          Enable postgres db.
        '';
      };

      dataPath = mkOption {
        type = types.path;
        default = "/var/lib/postgres";
        description = ''
          Path to the PostgreSQL data directory. If not set, uses the default
          PostgreSQL dataDir defined in services.postgresql.dataDir.
        '';
      };

      users = mkOption {
        type = types.listOf (
          types.submodule {
            options = {
              user = mkOption {
                type = types.str;
                description = ''
                  User name.
                '';
              };
              passwordFile = mkOption {
                type = types.path;
                description = ''
                  Path to a file containing the user's password (e.g. a sops-nix secret path).
                '';
              };
              database = mkOption {
                type = types.str;
                description = ''
                  Database.
                '';
              };
            };
          }
        );
        default = [ ];
        description = ''
          List of users.
        '';
      };

      authentication = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          Additional PostgreSQL authentication rules.
          Example: ["host all all 192.168.1.0/24 md5"]
        '';
      };
    };
  };

  config =
    let
      users = map (x: {
        name = x.user;
        ensureDBOwnership = true;
      }) cfg.users;

      databases = map (x: x.database) cfg.users;

      setPasswordsScript = map (
        x: "ALTER USER ${x.user} WITH PASSWORD '$(cat ${x.passwordFile})';"
      ) cfg.users;

      dataDir = cfg.dataPath;

      authenticationRules = strings.concatStringsSep "\n" (
        [
          "host all all 10.0.0.0/24 trust"
        ]
        ++ cfg.authentication
      );

      hasAuthentication = cfg.authentication != [ ];
    in
    mkIf cfg.enable {
      systemd.tmpfiles.rules = [ "d '${dataDir}' 0750 postgres postgres - -" ];

      services.postgresql = {
        enable = true;
        ensureDatabases = databases;
        ensureUsers = users;
        dataDir = dataDir;
        authentication = authenticationRules;

        enableTCPIP = mkIf hasAuthentication true;
      };

      systemd.services.set-user-password-in-db = {
        enable = true;
        description = "Set database user password";
        after = [
          "postgresql.service"
          "sops-nix.service"
        ];
        wants = [ "sops-nix.service" ];
        wantedBy = [ "multi-user.target" ];
        script = ''
          ${pkgs.postgresql}/bin/psql -v ON_ERROR_STOP=1 <<SQL
            ${strings.concatStrings setPasswordsScript}
          SQL
        '';

        serviceConfig = {
          User = "postgres";
          Group = "postgres";
          Type = "oneshot";
        };
      };

      networking.firewall.allowedTCPPorts = mkIf hasAuthentication [ 5432 ];
    };
}
