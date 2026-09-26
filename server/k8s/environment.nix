{ config, pkgs, ... }:

{
  # System packages for Kubernetes
  environment.systemPackages = with pkgs; [
    kubectl
    kubernetes-helm
    k3s
  ];

  # Set KUBECONFIG for kubectl access
  environment.variables.KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
}
