{ config, ... }:

{
  # Add k3s entry to /etc/hosts
  networking.hosts = {
    "127.0.0.1" = [ "k3s.local" ];
  };

  # Open firewall for k3s API server
  networking.firewall.allowedTCPPorts = [
    6443  # k3s API
  ];
}
