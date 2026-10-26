{ config, lib, ... }:

let
  # Only point k3s/containerd at the pull-through cache when it's actually
  # running — otherwise every docker.io pull hits a dead endpoint first,
  # mirroring the gating server/docker/service.nix does for the Docker
  # daemon's own registry-mirrors setting.
  mirrorEnabled = config.services.dockerRegistryMirror.enable;

  registriesYaml =
    lib.concatStringsSep "\n" (
      [
        "mirrors:"
        "  registry.home:"
        "    endpoint:"
        "      - https://registry.home"
      ]
      ++ lib.optionals mirrorEnabled [
        "  docker.io:"
        "    endpoint:"
        "      - https://registry.mirror"
      ]
      ++ [
        "configs:"
        "  registry.home:"
        "    tls:"
        "      ca_file: /var/lib/registry-certs/registry.home.crt"
      ]
      ++ lib.optionals mirrorEnabled [
        "  registry.mirror:"
        "    tls:"
        "      ca_file: /var/lib/registry-certs/registry.home.crt"
      ]
    )
    + "\n";
in
{
  # Configure k3s to work with Docker registry
  environment.etc."rancher/k3s/registries.yaml".text = registriesYaml;
}
