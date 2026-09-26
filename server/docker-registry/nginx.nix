{ config, ... }:

{
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;

    virtualHosts."registry.home" = {
      listen = [
        { addr = "0.0.0.0"; port = 443; ssl = true; }
      ];

      sslCertificate = "/var/lib/registry-certs/registry.home.crt";
      sslCertificateKey = "/var/lib/registry-certs/registry.home.key";

      locations."/" = {
        proxyPass = "http://127.0.0.1:5000";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Host $server_name;
        '';
      };
    };
  };

  # Ensure nginx waits for certificates to be in place
  systemd.services.nginx.after = [ "setup-registry-cert.service" ];
  systemd.services.nginx.requires = [ "setup-registry-cert.service" ];
}
