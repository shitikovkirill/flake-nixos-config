{ lib, ... }:

with lib;
{
  options.services.vaultwardenService = {
    enable = mkEnableOption "Vaultwarden password manager";

    domain = mkOption {
      type = types.str;
      example = "vault.example.com";
      description = "Domain name for Vaultwarden.";
    };

    https = mkOption {
      type = types.bool;
      default = false;
      description = "Use https:// in the DOMAIN URL (required by most Bitwarden clients).";
    };

    address = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = "Address Vaultwarden listens on.";
    };

    port = mkOption {
      type = types.port;
      default = 8222;
      description = "HTTP port (must be >= 1024, the service runs unprivileged).";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "Open the Vaultwarden port in the firewall.";
    };

    database = {
      backend = mkOption {
        type = types.enum [ "sqlite" "postgresql" ];
        default = "postgresql";
        description = "Database backend.";
      };

      name = mkOption {
        type = types.str;
        default = "vaultwarden";
        description = "PostgreSQL database name (created by a separate service).";
      };

      user = mkOption {
        type = types.str;
        default = "vaultwarden";
        description = ''
          PostgreSQL role. With socket peer auth it must match the system
          user "vaultwarden" (or be mapped via pg_ident).
        '';
      };

      host = mkOption {
        type = types.str;
        default = "/run/postgresql";
        example = "localhost";
        description = ''
          Unix socket directory (starts with "/") or TCP hostname.
          For password auth, put the full DATABASE_URL in environmentFile instead.
        '';
      };

      dependsOn = mkOption {
        type = types.listOf types.str;
        default = [ "postgresql.service" ];
        example = [ "postgresql.target" "my-db-setup.service" ];
        description = "systemd units that must be up before Vaultwarden starts.";
      };
    };

    environmentFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = "/run/secrets/vaultwarden.env";
      description = ''
        Environment file with secrets (e.g. ADMIN_TOKEN, DATABASE_URL),
        kept out of the Nix store. Values here override generated config.
      '';
    };

    extraConfig = mkOption {
      type = with types; attrsOf (nullOr (oneOf [ bool int str ]));
      default = { };
      example = { SMTP_HOST = "smtp.example.com"; };
      description = "Additional settings passed to services.vaultwarden.config.";
    };
  };
}