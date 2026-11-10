{
  sops.defaultSopsFile = ./vaultwarden.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  sops.secrets.vaultwarden_database_password = {
    key = "database/password";
    owner = "vaultwarden";
    group = "vaultwarden";
    mode = "0400";
  };

}
