{ config, pkgs, ... }:
let
  domain = "rabbitmq.home";
in
{
  imports = [ ../../service/rabbitmq ];

  services.rbService = {
    enable = true;
    https = false;
    openToWorld = true;
    inherit domain;
  };

  networking.hosts = {
    "127.0.0.1" = [ domain ];
  };
}
