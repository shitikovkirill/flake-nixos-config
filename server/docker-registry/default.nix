{ config, lib, ... }:

{
  imports = [
    ./certificates
    ./certificates/traefik.nix
    ./certificates/nginx.nix
    ./registry.nix
    ./mirror.nix
  ];

  services.dockerRegistryMirror.enable = true;

  # Add entry to /etc/hosts
  networking.hosts = {
    "127.0.0.1" = [ "registry.home" "registry.mirror" ];
  };
}
