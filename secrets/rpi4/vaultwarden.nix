{
  sops.defaultSopsFile = ./vaultwarden.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  sops.secrets.vaultwarden_database_password = {
    owner = "vaultwarden";
    group = "vaultwarden";
    mode = "0400";
  };

  sops.secrets.vaultwarden_domain = {
    owner = "vaultwarden";
    group = "vaultwarden";
    mode = "0400";
  };

}
