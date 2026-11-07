{ lib, ... }:

with lib;
{
  options = {
    services.vaultwardenService = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = "Enable Vaultwarden password manager.";
      };

      domain = mkOption {
        type = types.str;
        description = "Domain name for Vaultwarden.";
      };

      port = mkOption {
        type = types.port;
        default = 80;
        description = "HTTP port.";
      };

      databasePassword = mkOption {
        type = types.str;
        default = "";
        description = "PostgreSQL database password (deprecated, use databasePasswordFile).";
      };

      databasePasswordFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "Path to file containing PostgreSQL database password.";
      };

      databaseUser = mkOption {
        type = types.str;
        default = "vaultwarden";
        description = "PostgreSQL database user.";
      };

      restoreDuplicityBackup = mkOption {
        type = types.bool;
        default = false;
        description = "Restore database from duplicity backup on boot if DB is empty.";
      };

      duplicityRestorePath = mkOption {
        type = types.str;
        default = "/var/backup/duplicity";
        description = "Path where duplicity backups are stored.";
      };
    };
  };
}
