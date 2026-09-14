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
  };

  networking.hosts = {
    "127.0.0.1" = [ "k3s.local" ];
  };
}
