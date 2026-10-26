{ config, lib, ... }:

let
  # Both vhosts share the same cert (its SAN covers both hostnames) and TLS
  # settings — only the upstream port differs. Proxy headers (Host,
  # X-Real-IP, X-Forwarded-For, X-Forwarded-Proto) come from
  # recommendedProxySettings below, not set per-location here.
  mkRegistryVhost = port: {
    forceSSL = true;
    sslCertificate = "/var/lib/registry-certs/registry.home.crt";
    sslCertificateKey = "/var/lib/registry-certs/registry.home.key";

    locations."/" = {
      proxyPass = "http://localhost:${toString port}";
      proxyWebsockets = true;
    };

    # Registry health check endpoint
    locations."= /v2/" = {
      proxyPass = "http://localhost:${toString port}/v2/";
    };
  };
in
lib.mkIf (!(config.services.k3s.enable or false)) {
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."registry.home" = mkRegistryVhost 5000;
    virtualHosts."registry.mirror" = mkRegistryVhost 5001;
  };
}
