{ config, pkgs, ... }:

let
  # Official Flannel manifest from upstream, patched for k3s cluster CIDR (10.42.0.0/16)
  flannel-manifest = pkgs.runCommand "flannel-manifest.yaml" {
    buildInputs = [ pkgs.curl ];
  } ''
    curl -s https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml \
      | sed 's|"Network": "10.244.0.0/16"|"Network": "10.42.0.0/16"|g' > $out
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

    manifests.flannel = {
      source = flannel-manifest;
      target = "flannel.yaml";
    };
  };

  systemd.tmpfiles.rules = [
    "d /etc/rancher/k3s 0755 root root -"
  ];

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
