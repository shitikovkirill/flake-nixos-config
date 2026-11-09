{ lib, ... }:
let
  common = import ../common/default.nix { inherit lib; };
  inherit (lib) mkOption types;
in
{
  options.services.backuperService = common.options // {
    enable = lib.mkEnableOption "PostgreSQL and filesystem backups through Duplicity";

    include = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "/var/lib/vaultwarden" ];
      description = "Extra absolute filesystem paths to back up.";
    };

    databases = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "vaultwarden" ];
      description = "PostgreSQL databases to dump; empty means all if postgresql.enable is true.";
    };

    postgresql.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Create SQL dumps before Duplicity runs.";
    };

    postgresql.location = mkOption {
      type = types.str;
      default = "/var/backup/postgresql";
      description = "Directory for PostgreSQL dumps.";
    };

    frequency = mkOption {
      type = types.nullOr types.str;
      default = "*-*-* 03:00:00";
      description = "systemd calendar schedule; null disables scheduled runs.";
    };

    fullIfOlderThan = mkOption {
      type = types.str;
      default = "1M";
      description = "Interval between Duplicity full backup chains.";
    };

    maxAge = mkOption {
      type = types.nullOr types.str;
      default = "2M";
      description = "Delete backup chains older than this; null disables cleanup.";
    };

    extraFlags = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Additional nonsecret Duplicity command flags.";
    };
  };
}
