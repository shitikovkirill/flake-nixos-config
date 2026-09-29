# Generates a CA + server + client cert pair for the Docker remote API on
# first boot, entirely outside the Nix store (private keys must never land
# in /nix/store, which is world-readable) and owned by the docker service
# user. Re-running is a no-op once ca.pem exists. Copy client-cert.pem,
# client-key.pem and ca.pem from /home/docker/certs/ to whatever machine
# you want to control this daemon from.
{ config, pkgs, ... }:

let
  certDir = "/home/docker/certs";
in
{
  systemd.services.docker-tls-certs = {
    description = "Generate Docker daemon TLS certificates (CA/server/client) if missing";
    before = [ "docker.service" ];
    after = [ "systemd-tmpfiles-setup.service" ];
    requires = [ "systemd-tmpfiles-setup.service" ];
    unitConfig.ConditionPathExists = "!${certDir}/ca.pem";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "docker";
      Group = "docker";
    };
    path = [ pkgs.openssl ];
    script = ''
      set -euo pipefail
      umask 077
      mkdir -p ${certDir}
      cd ${certDir}

      openssl genrsa -out ca-key.pem 4096
      openssl req -new -x509 -days 3650 -key ca-key.pem -sha256 -out ca.pem \
        -subj "/CN=docker-ca-${config.networking.hostName}"

      openssl genrsa -out server-key.pem 4096
      openssl req -subj "/CN=${config.networking.hostName}" -sha256 -new \
        -key server-key.pem -out server.csr
      {
        echo "subjectAltName = DNS:${config.networking.hostName},IP:0.0.0.0"
        echo "extendedKeyUsage = serverAuth"
      } > extfile-server.cnf
      openssl x509 -req -days 3650 -sha256 -in server.csr -CA ca.pem -CAkey ca-key.pem \
        -CAcreateserial -out server-cert.pem -extfile extfile-server.cnf

      openssl genrsa -out client-key.pem 4096
      openssl req -subj "/CN=docker-client" -new -key client-key.pem -out client.csr
      echo "extendedKeyUsage = clientAuth" > extfile-client.cnf
      openssl x509 -req -days 3650 -sha256 -in client.csr -CA ca.pem -CAkey ca-key.pem \
        -CAcreateserial -out client-cert.pem -extfile extfile-client.cnf

      rm -f server.csr client.csr extfile-server.cnf extfile-client.cnf ca.srl
      chmod 0400 ca-key.pem server-key.pem client-key.pem
      chmod 0444 ca.pem server-cert.pem client-cert.pem
    '';
  };

  systemd.services.docker = {
    after = [ "docker-tls-certs.service" ];
    requires = [ "docker-tls-certs.service" ];
  };
}
