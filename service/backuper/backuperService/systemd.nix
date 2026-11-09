{ config, lib, ... }:
let
  cfg = config.services.backuperService;
  helper = import ./helpers.nix { inherit lib cfg; };
in
{
  config = lib.mkIf cfg.enable {
    systemd.services.duplicity = {
      requires = helper.postgresUnits;
      after = helper.postgresUnits ++ [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig.UMask = "0077";
    };
  };
}
