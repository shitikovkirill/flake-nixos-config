{
  sops.defaultSopsFile = ./vaultwarden.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  sops.secrets.vaultwarden_database_password = {
    owner = "vaultwarden";
    group = "vaultwarden";
    mode = "0400";
  };

  sops.secrets.backuper_passphrase = {
    owner = "root";
    group = "root";
    mode = "0400";
  };

  sops.secrets.backuper_s3_client_id = {
    owner = "root";
    group = "root";
    mode = "0400";
  };

  sops.secrets.backuper_s3_client_secret = {
    owner = "root";
    group = "root";
    mode = "0400";
  };

  sops.secrets.backuper_bucket_name = {
    owner = "root";
    group = "root";
    mode = "0400";
  };
}
