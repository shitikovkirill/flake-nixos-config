{ config, pkgs, ... }:

{
  system.stateVersion = "24.05";

  time.timeZone = "Europe/Amsterdam";

  security.acme = {
    defaults.email = "test@mail.com";
    acceptTerms = true;
  };

  imports = [ ./app.nix ];
}
