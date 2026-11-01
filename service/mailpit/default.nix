{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.mailpitService;

  proxy_pass = "http://127.0.0.1:${toString cfg.webPort}";

  ports = if cfg.openToWorld then [ cfg.smtpPort ] else [ ];

  smtpListen = if cfg.openToWorld then "0.0.0.0" else "127.0.0.1";
in
{
  options = {
    services.mailpitService = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = "Enable Mailpit service.";
      };

      https = mkOption {
        default = false;
        type = types.bool;
        description = "Enable HTTPS.";
      };

      domain = mkOption {
        type = types.str;
        description = "Service domain.";
      };

      environment = mkOption {
        type = types.attrsOf types.str;
        default = { };
        description = "Mailpit environment variables.";
      };

      openToWorld = mkOption {
        default = false;
        type = types.bool;
        description = "Expose SMTP to the network.";
      };

      smtpPort = mkOption {
        default = 1025;
        type = types.port;
        description = "SMTP port.";
      };

      webPort = mkOption {
        default = 8025;
        type = types.port;
        description = "Web UI port.";
      };
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [
      80 # HTTP
      443 # HTTPS
    ]
    ++ ports;

    services.nginx = {
      enable = true;
      recommendedGzipSettings = true;

      virtualHosts = {
        "${cfg.domain}" = {
          enableACME = cfg.https;
          forceSSL = cfg.https;

          locations = {
            "/" = {
              proxyPass = proxy_pass;
              proxyWebsockets = true;
            };
          };
        };
      };
    };

    systemd.services.mailpit = {
      description = "Mailpit Development SMTP Server";

      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      environment = {
        MP_DATABASE = "/var/lib/mailpit/mailpit.db";
      }
      // cfg.environment;

      serviceConfig = {
        Type = "simple";

        ExecStart = ''
          ${lib.getExe pkgs.mailpit} \
            --listen 127.0.0.1:${toString cfg.webPort} \
            --smtp ${smtpListen}:${toString cfg.smtpPort}
        '';

        Restart = "always";
        RestartSec = 5;

        DynamicUser = true;
        StateDirectory = "mailpit";
        WorkingDirectory = "/var/lib/mailpit";
      };
    };
  };
}
