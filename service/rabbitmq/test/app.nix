{
  config,
  pkgs,
  lib,
  ...
}:
let
  domain = "rabbitmq.local";
in
{
  imports = [ ../default.nix ];

  services.rbService = {
    enable = true;
    https = false;
    inherit domain;
  };

  networking.hosts = {
    "127.0.0.1" = [ domain ];
  };
}
