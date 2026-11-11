{ config, lib, pkgs, ... }:
let
  cfg = config.services.syncthingService;
  inherit (lib) mkOption mkEnableOption mkPackageOption mkIf mkDefault types;
in
{
  options.services.syncthingService = {
    enable = mkEnableOption "Syncthing service";

    package = mkPackageOption pkgs "syncthing" { };

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
      description = "Home/working directory; default parent for synced folders.";
    };

    configDir = mkOption {
      type = types.path;
      default = "${cfg.dataDir}/config";
      defaultText = lib.literalExpression ''"''${config.services.syncthingService.dataDir}/config"'';
      description = "Directory for Syncthing config, keys and certificates.";
    };

    databaseDir = mkOption {
      type = types.path;
      default = cfg.configDir;
      defaultText = lib.literalExpression "config.services.syncthingService.configDir";
      description = "Directory for the Syncthing index database.";
    };

    openDefaultPorts = mkOption {
      type = types.bool;
      default = true;
      description = "Open Syncthing ports in firewall (22000/tcp+udp, 21027/udp).";
    };

    guiAddress = mkOption {
      type = types.str;
      default = "127.0.0.1:8384";
      description = "Address and port for the web GUI.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !config.services.syncthing.enable;
        message = "services.syncthingService conflicts with the upstream services.syncthing module; enable only one.";
      }
    ];

    networking.firewall = mkIf cfg.openDefaultPorts {
      allowedTCPPorts = [ 22000 ];
      allowedUDPPorts = [ 22000 21027 ];
    };

    # Create the default user/group only when the defaults are used
    users.users = mkIf (cfg.user == "syncthing") {
      syncthing = {
        isSystemUser = true;
        group = cfg.group;
        home = cfg.dataDir;
      };
    };

    users.groups = mkIf (cfg.group == "syncthing") {
      syncthing = { };
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}'     0700 ${cfg.user} ${cfg.group} - -"
      "d '${cfg.configDir}'   0700 ${cfg.user} ${cfg.group} - -"
      "d '${cfg.databaseDir}' 0700 ${cfg.user} ${cfg.group} - -"
    ];

    # Named "syncthing" so this module owns syncthing.service.
    systemd.services.syncthing = {
      description = "Syncthing service";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      # mkDefault: stray definitions elsewhere override instead of conflicting
      environment = {
        STNORESTART = mkDefault "yes";
        STNOUPGRADE = mkDefault "yes";
        STNODEFAULTFOLDER = mkDefault "yes";
      };

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.dataDir;

        ExecStart = lib.concatStringsSep " " [
          (lib.getExe cfg.package)
          "serve"
          "--no-browser"
          "--gui-address=${cfg.guiAddress}"
          "--config=${cfg.configDir}"
          "--data=${cfg.databaseDir}"
        ];

        Restart = "on-failure";
        RestartSec = 5;
        SuccessExitStatus = "3 4";
        RestartForceExitStatus = "3 4";

        # Basic hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "full";
      };
    };
  };
}