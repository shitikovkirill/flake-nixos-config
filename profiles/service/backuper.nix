{ config, ... }:

{
  imports = [ ../../service/backuper ];

  services.backuperService = {
    enable = false;

    databases = [ "vaultwarden" ];
    include = [ "/var/lib/vaultwarden" ];

    target = "boto3+s3://webwave-backup-folder/duplicity";

    secretFile = config.sops.secrets.backuper.path;

    frequency = "*-*-* 03:00:00";
    fullIfOlderThan = "1M";
    maxAge = "2M";
  };

  services.restoreService = {
    enable = true;

    target = "boto3+s3://webwave-backup-folder/duplicity";

    secretFile = config.sops.secrets.backuper.path;

    directory = "/ssd/var/lib/backuper/restore";

    time = null;
  };

}
