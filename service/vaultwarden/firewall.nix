{ config, lib, ... }:

with lib;
let
  cfg = config.services.vaultwardenService;
in
{
  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
