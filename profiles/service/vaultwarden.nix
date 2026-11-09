{ config, ... }:

{
  imports = [ ../../service/vaultwarden ];

  services.vaultwardenService = {
    enable = true;
    domain = config.sops.secrets.vaultwarden_domain.path;
    databasePasswordFile = config.sops.secrets.vaultwarden_database_password.path;
    databaseUser = "vaultwarden";
    port = 80;
    restoreDuplicityBackup = true;
    duplicityRestorePath = "/var/backup/duplicity";
  };
}
