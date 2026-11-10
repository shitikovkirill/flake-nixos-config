{
  sops.defaultSopsFile = ./vaultwarden.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  sops.secrets.vaultwarden_database_password = {
    key = "database/password";
    owner = "postgres";
    group = "postgres";
    mode = "0400";
  };

}
