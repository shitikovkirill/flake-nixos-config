{ config, ... }:

{
  imports = [ ../../service/backuper ];

  services.backuperService = {
    enable = false;
    databases = [ "vaultwarden" ];
    include = [ "/var/lib/vaultwarden" ];
    pathPhraseFile = config.sops.secrets.backuper_passphrase.path;
    s3 = {
      enable = true;
      clientIdFile = config.sops.secrets.backuper_s3_client_id.path;
      clientSecretFile = config.sops.secrets.backuper_s3_client_secret.path;
      bucketNameFile = config.sops.secrets.backuper_bucket_name.path;
      region = "us-east-1";
    };
  };
}
