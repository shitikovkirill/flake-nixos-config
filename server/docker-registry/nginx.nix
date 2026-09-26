{ config, ... }:

{
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;

    virtualHosts."registry.home" = {
      forceSSL = true;

      sslCertificate = "/var/lib/registry-certs/registry.home.crt";
      sslCertificateKey = "/var/lib/registry-certs/registry.home.key";

      locations."/" = {
        proxyPass = "http://127.0.0.1:5000";
        extraConfig = ''
          client_max_body_size 0;
          proxy_read_timeout 900;
          proxy_send_timeout 900;
        '';
      };
    };
  };

  # Ensure nginx waits for certificates to be in place
  systemd.services.nginx.after = [ "setup-registry-cert.service" ];
  systemd.services.nginx.requires = [ "setup-registry-cert.service" ];
}
