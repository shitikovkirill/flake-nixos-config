{
  imports = [
    ./certificate.nix
    ./registry.nix
  ];

  # Add entry to /etc/hosts
  networking.hosts = {
    "127.0.0.1" = [ "registry.home" ];
  };
}
