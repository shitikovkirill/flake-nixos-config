{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.custom.devServerConfig;
  user = cfg.user;
  codePath = cfg.codePath;
in {
  options = {
    custom.devServerConfig = {
      user = mkOption {
        default = "nixos";
        type = types.str;
        description = "The default username for your system.";
        example = "exampleUser";
      };
      codePath = mkOption {
        default = "~/Development";
        type = types.str;
        description = "The default code directory for your system.";
        example = "~/Development";
      };
    };
  };

  imports = [ ./vs_code ./aliases.nix ./users ];

}
