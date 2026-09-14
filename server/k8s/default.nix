{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    kubectl
    kubernetes-helm
    k3s
  ];

  services.k3s = {
    enable = true;
    role = "server";
    nodeName = "k3s.local";
    serverAddr = "https://k3s.local:6443";
  };

  networking.hosts = {
    "127.0.0.1" = [ "k3s.local" ];
  };

  # ip -br addr | grep 172.18.0.1
  networking.firewall.interfaces."br-07e876555d46".allowedTCPPorts = [
    6443
  ];
}
