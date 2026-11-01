{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.rbService;
  proxy_pass = "http://127.0.0.1:${toString config.services.rabbitmq.managementPlugin.port}";
  ports = if cfg.openToWorld then [ config.services.rabbitmq.port ] else [ ];
  listen = if cfg.openToWorld then { listenAddress = "0.0.0.0"; } else { };
in
{

  options = {
    services.rbService = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = ''
          Enable rebbitmq service.
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
        description = ''
          Service domain.
        '';
      };

      environment = mkOption {
        type = types.attrs;
        default = { };
        description = ''
          Add environment to systemd.
        '';
      };

      openToWorld = mkOption {
        default = false;
        type = types.bool;
        description = ''
          Open to world.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [
      80 # HTTP
      443 # HTTPs
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
            };
          };
        };
      };
    };

    services.rabbitmq = {
      enable = true;
      plugins = [ "rabbitmq_prometheus" ];
      managementPlugin.enable = true;
      configItems = cfg.environment;
    }
    // listen;
  };
}
