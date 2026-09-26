{ config, pkgs, ... }:

{
  # System packages for Kubernetes
  environment.systemPackages = with pkgs; [
    kubectl
    kubernetes-helm
    k3s
  ];

}
