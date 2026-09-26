{ config, pkgs, ... }:

{
  # Create k3s user for data directory ownership
  users.users.k3s = {
    isSystemUser = true;
    group = "k3s";
    home = "/home/k3s";
    createHome = true;
  };

  users.groups.k3s = {};

  # k3s Kubernetes service
  services.k3s = {
    enable = true;
    role = "server";
    serverAddr = "https://k3s.local:6443";
    extraFlags = "--data-dir=/home/k3s/data";
  };

  # Ensure k3s waits for network and registry certificate
  systemd.services.k3s.after = [ "network-online.target" "setup-registry-cert.service" ];
  systemd.services.k3s.wants = [ "setup-registry-cert.service" ];
  systemd.services.k3s.requires = [ "network-online.target" ];

  # Setup k3s directories
  systemd.tmpfiles.rules = [
    "d /etc/rancher/k3s 0755 root root -"
    "d /home/k3s 0755 k3s k3s -"
    "d /home/k3s/data 0755 k3s k3s -"
  ];
}
