{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.pgadminService;
in
{

  options = {
    services.pgadminService = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = ''
          Enable pgadmin.
        '';
      };

      https = mkOption {
        default = false;
        type = types.bool;
        description = ''
          Enable https.
        '';
      };

      domain = mkOption {
        type = types.str;
        description = "Domain.";
      };

      email = mkOption {
        type = types.str;
        description = lib.mdDoc ''
          Email.
        '';
      };

      passwordFile = mkOption {
        type = types.path;
        description = lib.mdDoc ''
          Path to a file containing the initial admin password (e.g. a sops-nix secret path).
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [
      80 # HTTP
      443 # HTTPs
    ];

    systemd.services.pgadmin = {
      after = [ "sops-nix.service" ];
      wants = [ "sops-nix.service" ];
    };

    services.pgadmin = {
      enable = true;
      initialPasswordFile = cfg.passwordFile;
      initialEmail = cfg.email;
      settings = {
        ALLOWED_HOSTS = [
          cfg.domain
          "127.0.0.1"
        ];
        DEBUG = true;
      };
    };

    services.nginx = {
      enable = true;
      statusPage = true;

      virtualHosts = {
        "${cfg.domain}" = {
          enableACME = cfg.https;
          forceSSL = cfg.https;
          locations = {
            "/" = {
              proxyPass = "http://127.0.0.1:${toString config.services.pgadmin.port}";
            };
            "/api/live/ws" = {
              proxyWebsockets = true;
              proxyPass = "http://127.0.0.1:${toString config.services.pgadmin.port}";
            };
          };
        };
      };
    };
  };
}
