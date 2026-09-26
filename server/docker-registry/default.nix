{ config, ... }:

let
  # Auto-detect TLS backend based on k3s availability
  useK3s = config.services.k3s.enable or false;
  tlsBackend = if useK3s then "traefik" else "nginx";
in
{
  imports = [
    ./certificates
    ./registry.nix
  ] ++ (
    if tlsBackend == "traefik" then
      [ ./certificates/traefik.nix ]
    else
      [ ./certificates/nginx.nix ]
  );

  # Add entry to /etc/hosts
  networking.hosts = {
    "127.0.0.1" = [ "registry.home" ];
  };

  # Configuration option for TLS backend (can override auto-detection)
  options.services.dockerRegistry.tlsBackend = {
    type = "str";
    default = tlsBackend;
    description = "TLS termination backend: 'traefik' (requires k3s) or 'nginx'. Auto-detects based on k3s.enable.";
  };
}
