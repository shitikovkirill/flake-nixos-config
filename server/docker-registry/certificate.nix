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

  # Wait for Kubernetes API server to be ready
  waitForK8s = pkgs.writeShellScript "wait-for-k8s" ''
    for i in {1..60}; do
      if ${pkgs.kubectl}/bin/kubectl --kubeconfig=/etc/rancher/k3s/k3s.yaml cluster-info &>/dev/null; then
        exit 0
      fi
      echo "Waiting for Kubernetes API server... ($i/60)"
      sleep 1
    done
    echo "Kubernetes API server did not become ready after 60 seconds"
    exit 1
  '';

  # Script to update Traefik Secret with new certificate
  updateTraefikSecret = pkgs.writeShellScript "update-traefik-secret" ''
    set -e

    ${waitForK8s}

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

  # Script to apply registry manifests after Secret is created
  applyRegistryManifests = pkgs.writeShellScript "apply-registry-manifests" ''
    set -e

    ${waitForK8s}

    ${pkgs.kubectl}/bin/kubectl apply -f ${./registry.yaml}
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

  # Apply registry manifests (IngressRoute, Service, TLSStore) after Secret is updated
  systemd.services.apply-registry-manifests = {
    description = "Apply Traefik registry manifests";
    after = [ "update-traefik-registry-secret.service" ];
    wants = [ "update-traefik-registry-secret.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = applyRegistryManifests;
      RemainAfterExit = true;
    };
    environment.KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
  };

  # Trust the self-signed certificate
  security.pki.certificateFiles = [ "${registryCert}/registry.home.crt" ];
}
