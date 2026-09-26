{ pkgs, ... }:

{
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."registry.home" = {
      forceSSL = true;
      sslCertificate = "/var/lib/registry-certs/registry.home.crt";
      sslCertificateKey = "/var/lib/registry-certs/registry.home.key";
      sslProtocols = [ "TLSv1.2" "TLSv1.3" ];
      sslCiphers = "HIGH:!aNULL:!MD5";

      locations."/" = {
        proxyPass = "http://localhost:5000";
        proxyWebsockets = true;
        extraProxyHeaders = {
          "Host" = "$host";
          "X-Real-IP" = "$remote_addr";
          "X-Forwarded-For" = "$proxy_add_x_forwarded_for";
          "X-Forwarded-Proto" = "$scheme";
        };
      };

      # Docker registry health check endpoint
      locations."= /v2/" = {
        proxyPass = "http://localhost:5000/v2/";
      };
    };
  };
}
