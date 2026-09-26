{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    kubectl
    kubernetes-helm
    k3s
  ];

  # Create k3s user for data directory ownership
  users.users.k3s = {
    isSystemUser = true;
    group = "k3s";
    home = "/home/k3s";
    createHome = true;
  };

  users.groups.k3s = {};

  services.k3s = {
    enable = true;
    role = "server";
    serverAddr = "https://k3s.local:6443";
    extraFlags = "--data-dir=/home/k3s/data";
  };

  # Ensure k3s waits for registry certificate
  systemd.services.k3s.after = [ "setup-registry-cert.service" ];
  systemd.services.k3s.wants = [ "setup-registry-cert.service" ];

  # Set KUBECONFIG for kubectl access
  environment.variables.KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";

  systemd.tmpfiles.rules = [
    "d /etc/rancher/k3s 0755 root root -"
    "d /home/k3s 0755 k3s k3s -"
    "d /home/k3s/data 0755 k3s k3s -"
  ];

  environment.etc."rancher/k3s/registries.yaml" = {
    text = ''
      mirrors:
        registry.home:
          endpoint:
            - https://registry.home
      configs:
        registry.home:
          tls:
            ca_file: /var/lib/registry-certs/registry.home.crt
    '';
  };

  networking.hosts = {
    "127.0.0.1" = [ "k3s.local" ];
  };

  networking.firewall.allowedTCPPorts = [
    6443
  ];
}
