{ pkgs, config, lib, ... }:

let
  certDir = "/var/lib/registry-certs";

  # Helper scripts
  scriptsDir = ./scripts;

  waitForK8s = pkgs.writeShellScriptBin "wait-for-k8s" (builtins.readFile (scriptsDir + "/wait-for-k8s.sh"));

  updateTraefikSecret = pkgs.writeShellScriptBin "update-traefik-secret" (
    (builtins.readFile (scriptsDir + "/update-traefik-secret.sh"))
  );

  applyRegistryManifests = pkgs.writeShellScriptBin "apply-registry-manifests" (builtins.readFile (scriptsDir + "/apply-registry-manifests.sh"));

in
lib.mkIf (config.services.k3s.enable or false) {
  # Update Traefik Secret after certificate is set up
  systemd.services.update-traefik-registry-secret = {
    description = "Update Traefik Secret with registry certificate";
    after = [ "setup-registry-cert.service" "k3s.service" ];
    wants = [ "setup-registry-cert.service" ];
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [ kubectl ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${updateTraefikSecret}/bin/update-traefik-secret";
      RemainAfterExit = true;
    };
    environment = {
      KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
      CERT_DIR = certDir;
      WAIT_FOR_K8S_SCRIPT = "${waitForK8s}/bin/wait-for-k8s";
    };
  };

  # Apply registry manifests (IngressRoute, Service, TLSStore) after Secret is updated
  systemd.services.apply-registry-manifests = {
    description = "Apply Traefik registry manifests";
    after = [ "update-traefik-registry-secret.service" ];
    wants = [ "update-traefik-registry-secret.service" ];
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [ kubectl coreutils gawk ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${applyRegistryManifests}/bin/apply-registry-manifests";
      RemainAfterExit = true;
    };
    environment = {
      KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
      REGISTRY_MANIFEST_PATH = "${./registry.yaml}";
      WAIT_FOR_K8S_SCRIPT = "${waitForK8s}/bin/wait-for-k8s";
    };
  };
}
