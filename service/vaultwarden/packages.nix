{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.vaultwardenService;
in
{
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      vaultwarden
      postgresql
    ];
  };
}
