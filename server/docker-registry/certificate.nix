{ pkgs, config, ... }:

let
  registryCert = pkgs.runCommand "registry-home-cert" {
    buildInputs = [ pkgs.openssl ];
  } ''
    mkdir -p $out
    openssl req -x509 -newkey rsa:4096 \
      -keyout $out/registry.home.key -out $out/registry.home.crt \
      -days 365 -nodes \
      -subj "/C=RU/ST=Moscow/L=Moscow/O=Home/CN=registry.home" \
      -addext "subjectAltName=DNS:registry.home"
  '';

  certDir = "/var/lib/registry-certs";

  # Script to update Traefik Secret with new certificate
  updateTraefikSecret = pkgs.writeShellScript "update-traefik-secret" ''
    set -e

    CERT=$(cat ${certDir}/registry.home.crt | base64 -w0)
    KEY=$(cat ${certDir}/registry.home.key | base64 -w0)

    # Create temporary Secret manifest
    cat > /tmp/registry-secret.yaml << EOF
apiVersion: v1
kind: Secret
metadata:
  name: registry-home-tls
  namespace: kube-system
type: kubernetes.io/tls
data:
  tls.crt: $CERT
  tls.key: $KEY
EOF

    # Apply the secret (recreate if exists)
    ${pkgs.kubectl}/bin/kubectl apply -f /tmp/registry-secret.yaml

    # Clean up
    rm -f /tmp/registry-secret.yaml
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
    serviceConfig.Type = "oneshot";
    script = ''
      cp ${registryCert}/registry.home.crt ${certDir}/registry.home.crt
      cp ${registryCert}/registry.home.key ${certDir}/registry.home.key
      chmod 644 ${certDir}/registry.home.crt
      chmod 644 ${certDir}/registry.home.key
    '';
  };

  # Update Traefik Secret after certificate is set up
  systemd.services.update-traefik-registry-secret = {
    description = "Update Traefik Secret with registry certificate";
    after = [ "setup-registry-cert.service" "k3s.service" ];
    wants = [ "setup-registry-cert.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = updateTraefikSecret;
      RemainAfterExit = true;
    };
    environment.KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
  };

  # Trust the self-signed certificate
  security.pki.certificateFiles = [ "${registryCert}/registry.home.crt" ];
}
