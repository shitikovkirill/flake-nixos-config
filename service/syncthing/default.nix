{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.syncthingService;
in
{
  options = {
    services.syncthingService = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = "Enable Syncthing service.";
      };

      user = mkOption {
        type = types.str;
        default = "syncthing";
        description = "User to run Syncthing as.";
      };

      group = mkOption {
        type = types.str;
        default = "syncthing";
        description = "Group to run Syncthing as.";
      };

      dataDir = mkOption {
        type = types.path;
        default = "/var/lib/syncthing";
        description = "Directory for synced folders.";
      };

      configDir = mkOption {
        type = types.path;
        description = "Directory for Syncthing config, keys, and certificates.";
      };

      openDefaultPorts = mkOption {
        default = true;
        type = types.bool;
        description = "Open Syncthing ports in firewall (22000/tcp+udp, 21027/udp).";
      };

      guiAddress = mkOption {
        type = types.str;
        default = "127.0.0.1:8384";
        description = "Address and port for the web GUI.";
      };
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = mkIf cfg.openDefaultPorts [ 22000 ];
    networking.firewall.allowedUDPPorts = mkIf cfg.openDefaultPorts [ 22000 21027 ];

    systemd.services.syncthing = {
      description = "Syncthing service";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "notify";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${lib.getExe pkgs.syncthing} -no-browser -gui-address=${cfg.guiAddress}";
        Restart = "on-failure";
        RestartSec = 5;

        StateDirectory = baseNameOf cfg.dataDir;
        WorkingDirectory = cfg.dataDir;
      };

      environment = {
        STNORESTART = "1";
        STNODEFAULTFOLDER = "1";
      };
    };
  };
}
