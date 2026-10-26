{ config, ... }:

{
  # Docker remote API access (TLS client-cert auth, see ./tls.nix)
  networking.firewall.allowedTCPPorts = [
    2376  # Docker remote API (TLS)
  ];
}
