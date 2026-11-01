{ config, pkgs, ... }:
let
  domain = "mail.home";
in
{
  imports = [ ../../service/mailpit ];

  services.mailpitService = {
    enable = true;
    https = false;
    inherit domain;

    openToWorld = true;

    smtpPort = 1025;
    webPort = 8025;

    environment = {
      MP_MAX_MESSAGES = "10000";
      MP_DISABLE_VERSION_CHECK = "true";
    };
  };

  networking.hosts = {
    "127.0.0.1" = [ domain ];
  };
}
