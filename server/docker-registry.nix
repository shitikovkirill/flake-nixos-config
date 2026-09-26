{ config, pkgs, ... }:

let
  # Generate self-signed certificate as a Nix derivation
  registryCert = pkgs.runCommand "registry-home-cert" {
    buildInputs = [ pkgs.openssl ];
  } ''
    mkdir -p $out
    openssl req -x509 -newkey rsa:4096 \
      -keyout $out/registry.home.key -out $out/registry.home.crt \
      -days 365 -nodes \
      -subj "/C=RU/ST=Moscow/L=Moscow/O=Home/CN=registry.home"
  '';

  certDir = "/var/lib/registry-certs";
  certFile = "${certDir}/registry.home.crt";
  keyFile = "${certDir}/registry.home.key";
in
{
  # Built-in Docker Registry (Native NixOS)
  # Note: The dockerRegistry module automatically creates a 'docker-registry'
  # system user and uses it to run the service, so we don't need to declare it
  services.dockerRegistry = {
    enable = true;
    port = 5000;
    storagePath = "/home/docker-registry/data";

    extraConfig = {
      delete.enabled = true;
      storage.redirect.disable = false;
    };
  };

  # Setup certificate directory and copy certificates
  systemd.tmpfiles.rules = [
    "d ${certDir} 0755 root root -"
  ];

  systemd.services.setup-registry-cert = {
    description = "Setup self-signed certificate for Docker registry";
    before = [ "nginx.service" ];
    wantedBy = [ "multi-user.target" ];
    type = "oneshot";
    script = ''
      cp ${registryCert}/registry.home.crt ${certFile}
      cp ${registryCert}/registry.home.key ${keyFile}
      chmod 644 ${certFile}
      chmod 600 ${keyFile}
    '';
  };

  # Trust the self-signed certificate
  security.pki.certificateFiles = [ "${registryCert}/registry.home.crt" ];

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;

    virtualHosts."registry.home" = {
      listen = [
        { addr = "0.0.0.0"; port = 443; ssl = true; }
      ];

      sslCertificate = certFile;
      sslCertificateKey = keyFile;

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

  # Open ports in firewall
  networking.firewall.allowedTCPPorts = [
    443   # nginx (HTTPS)
  ];

  # Add entry to /etc/hosts
  networking.hosts = {
    "127.0.0.1" = [ "registry.home" ];
  };
}
