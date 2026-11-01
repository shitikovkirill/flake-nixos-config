{
  sops.defaultSopsFile = ./pg.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  sops.secrets.postgres_vtb_password = {
    owner = "postgres";
    group = "postgres";
  };
  sops.secrets.pgadmin_password = { };
}
