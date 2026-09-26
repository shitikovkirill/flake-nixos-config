{ config, ... }:

{
  # Configure k3s to work with Docker registry
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
}
