{
  imports = [
    ./certificate.nix
    ./registry.nix
    ./nginx.nix
  ];

  # Open firewall for HTTPS
  networking.firewall.allowedTCPPorts = [
    443   # nginx (HTTPS)
  ];

  # Add entry to /etc/hosts
  networking.hosts = {
    "127.0.0.1" = [ "registry.home" ];
  };
}
