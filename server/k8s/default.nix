{ config, pkgs, lib, ... }:

let
  deploy-flannel = pkgs.writeShellScript "deploy-flannel.sh" ''
    set -e

    # Wait for k3s to be ready
    while ! kubectl get nodes &>/dev/null; do
      echo "Waiting for k3s API..."
      sleep 2
    done

    # Check if kube-flannel namespace already exists
    if ! kubectl get namespace kube-flannel &>/dev/null; then
      echo "Deploying Flannel CNI..."
      kubectl apply -f /etc/k3s/flannel-manifest.yaml
    else
      # Update configmap with correct subnet
      kubectl patch configmap kube-flannel-cfg -n kube-flannel --type merge -p '{"data":{"net-conf.json":"{\"Network\":\"10.42.0.0/16\",\"Backend\":{\"Type\":\"vxlan\"}}"}}' || true
    fi
  '';
in
{
  environment.systemPackages = with pkgs; [
    kubectl
    kubernetes-helm
    k3s
  ];

  services.k3s = {
    enable = true;
    role = "server";
    serverAddr = "https://k3s.local:6443";
    extraFlags = "--flannel-backend=vxlan";
  };

  systemd.services.k3s-flannel-deploy = {
    description = "Deploy Flannel CNI for k3s";
    after = [ "k3s.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Environment = "KUBECONFIG=/etc/rancher/k3s/k3s.yaml";
      ExecStart = deploy-flannel;
    };
  };

  systemd.tmpfiles.rules = [
    "d /etc/rancher/k3s 0755 root root -"
    "d /etc/k3s 0755 root root -"
  ];

  environment.etc."k3s/flannel-manifest.yaml".source = ./flannel-manifest.yaml;

  environment.etc."rancher/k3s/registries.yaml" = {
    text = ''
      mirrors:
        registry.home:5000:
          endpoint:
            - http://registry.home:5000
      configs:
        registry.home:5000:
          tls:
            insecure_skip_verify: true
    '';
  };

  networking.hosts = {
    "127.0.0.1" = [ "k3s.local" "registry.home" ];
  };

  networking.firewall.allowedTCPPorts = [
    6443
    5000
  ];
}
