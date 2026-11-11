{ pkgs, ... }:

{

    imports = [
        ../../service/vaultwarden
    ];

  services.vaultwardenService = {
    enable = true;
    domain = "vault.home";
    https = true;
    address = "127.0.0.1";
    port = 8222;
    openFirewall = false;
    database.backend = "postgresql";
    # Defaults: name/user "vaultwarden", socket /run/postgresql.
    # Set dependsOn to the unit of your DB-creating service, e.g.:
    database.dependsOn = [ "postgresql.service" "set-user-password-in-db.service" ];
  };

  services.caddy = {
    enable = true;
    globalConfig = ''
      skip_install_trust
    '';
    virtualHosts."vault.home".extraConfig = ''
      tls internal
      reverse_proxy 127.0.0.1:8222
    '';
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}