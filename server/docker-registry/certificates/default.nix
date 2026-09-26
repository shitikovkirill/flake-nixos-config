{ pkgs, config, ... }:

let
  registryCert = pkgs.runCommand "registry-home-cert" {
    buildInputs = [ pkgs.openssl ];
  } ''
    mkdir -p $out

    # Create a config file for proper SAN support
    cat > /tmp/cert.conf << 'CONF'
    [req]
    distinguished_name = req_distinguished_name
    req_extensions = v3_req
    prompt = no

    [req_distinguished_name]
    C = RU
    ST = Moscow
    L = Moscow
    O = Home
    CN = registry.home

    [v3_req]
    subjectAltName = DNS:registry.home
    CONF

    openssl req -x509 -newkey rsa:4096 \
      -keyout $out/registry.home.key -out $out/registry.home.crt \
      -days 365 -nodes -config /tmp/cert.conf \
      -extensions v3_req
  '';

  certDir = "/var/lib/registry-certs";

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
    serviceConfig.Type = "oneshot";
    script = ''
      cp ${registryCert}/registry.home.crt ${certDir}/registry.home.crt
      cp ${registryCert}/registry.home.key ${certDir}/registry.home.key
      chmod 644 ${certDir}/registry.home.crt
      chmod 644 ${certDir}/registry.home.key
    '';
  };

  # Trust the self-signed certificate
  security.pki.certificateFiles = [ "${registryCert}/registry.home.crt" ];
}
