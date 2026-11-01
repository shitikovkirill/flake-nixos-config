{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.minioService;

  proxy_pass = "http://127.0.0.1${config.services.minio.listenAddress}";
  proxy_pass_console = "http://127.0.0.1${config.services.minio.consoleAddress}";

  env = pkgs.writeText "minio-env" "MINIO_BROWSER_REDIRECT_URL=${
    if cfg.https then "https" else "http"
  }://ui.${cfg.domain}/";
in
{

  options = {
    services.minioService = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = ''
          Enable minio service.
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

      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/minio/data";
        example = "/mnt/storage/minio/data";
        description = "Directory for MinIO object storage data.";
      };
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [
      80 # HTTP
      443 # HTTPs
    ];

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
        "ui.${cfg.domain}" = {
          enableACME = cfg.https;
          forceSSL = cfg.https;
          locations = {
            "/" = {
              proxyPass = proxy_pass_console;
              proxyWebsockets = true;
              extraConfig = ''
                add_header X-Debug-Upstream $upstream_status always;
                add_header X-Debug-Backend $upstream_addr always;
              '';
            };
          };
        };
      };
    };

    services.minio = {
      enable = true;
      rootCredentialsFile = env;
      dataDir = [ cfg.dataDir ];
    };

    # Create minio data directory
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0755 minio minio -"
    ];

    systemd.services.minio.serviceConfig.ProtectHome = lib.mkIf (lib.hasPrefix "/home/" cfg.dataDir) (
      lib.mkForce false
    );
  };
}
