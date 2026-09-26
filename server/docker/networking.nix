{ config, ... }:

{
  # Docker remote API access
  networking.firewall.allowedTCPPorts = [
    2375  # Docker remote API
  ];
}
