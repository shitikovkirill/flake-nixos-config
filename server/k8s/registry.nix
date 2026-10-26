{ config, lib, pkgs, ... }:

let
  # Only point k3s/containerd at the pull-through cache when it's actually
  # running — otherwise every docker.io pull hits a dead endpoint first,
  # mirroring the gating server/docker/service.nix does for the Docker
  # daemon's own registry-mirrors setting.
  mirrorEnabled = (config.services.dockerRegistryMirror or { }).enable or false;

  registriesConfig = {
    mirrors = {
      "registry.home".endpoint = [ "https://registry.home" ];
    } // lib.optionalAttrs mirrorEnabled {
      "docker.io".endpoint = [ "https://registry.mirror" ];
    };
    configs = {
      "registry.home".tls.ca_file = "/var/lib/registry-certs/registry.home.crt";
    } // lib.optionalAttrs mirrorEnabled {
      "registry.mirror".tls.ca_file = "/var/lib/registry-certs/registry.home.crt";
    };
  };
in
{
  # Configure k3s to work with Docker registry
  environment.etc."rancher/k3s/registries.yaml".source =
    (pkgs.formats.yaml { }).generate "registries.yaml" registriesConfig;
}
