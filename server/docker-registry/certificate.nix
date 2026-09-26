{ pkgs, config, ... }:

let
  certDir = "/var/lib/registry-certs";
  certFile = "${certDir}/registry.home.crt";
  keyFile = "${certDir}/registry.home.key";

  registryCert = pkgs.runCommand "registry-home-cert" {
    buildInputs = [ pkgs.openssl ];
  } ''
    mkdir -p $out
    openssl req -x509 -newkey rsa:4096 \
      -keyout $out/registry.home.key -out $out/registry.home.crt \
      -days 365 -nodes \
      -subj "/C=RU/ST=Moscow/L=Moscow/O=Home/CN=registry.home"
  '';
in
{
  imports = [];

  # Setup certificate directory
  systemd.tmpfiles.rules = [
    "d ${certDir} 0755 root root -"
  ];

  # Copy generated certificates to runtime location
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
}
