{ config, ... }:

{
  imports = [ ../../service/vaultwarden ];

  services.vaultwardenService = {
    enable = true;
    domain = "vault.local";
    databasePasswordFile = config.sops.secrets.vaultwarden_database_password.path;
    databaseUser = "vaultwarden";
    port = 80;
    restoreDuplicityBackup = true;
    duplicityRestorePath = "/var/backup/duplicity";
  };
}
