{ config, lib, pkgs, ... }:
let
  cfg = config.services.restoreService;
  common = import ../common/default.nix { inherit lib; };
  restoreScript = pkgs.writeShellScript "restore-service" ''
    set -euo pipefail
    umask 077

    destination=${lib.escapeShellArg cfg.directory}
    if [ -L "$destination" ]; then
      echo "Refusing symlink destination: $destination" >&2
      exit 1
    fi
    if [ -e "$destination" ] && [ ! -d "$destination" ]; then
      echo "Destination is not a directory: $destination" >&2
      exit 1
    fi
    if [ -d "$destination" ] && [ -n "$( ${pkgs.coreutils}/bin/ls -A -- "$destination")" ]; then
      echo "Destination must be empty: $destination" >&2
      exit 1
    fi

    ${pkgs.coreutils}/bin/mkdir -p -- "$destination"
    ${pkgs.coreutils}/bin/chmod 0700 -- "$destination"

    exec ${lib.getExe pkgs.duplicity} restore \
      ${lib.escapeShellArgs (lib.optionals (cfg.time != null) [ "--time" cfg.time ])} \
      ${lib.escapeShellArg cfg.target} "$destination"
  '';
in
{
  config = lib.mkIf cfg.enable {
    assertions = common.helpers.endpointAssertions "services.restoreService" cfg ++ [
      {
        assertion = lib.hasPrefix "/" cfg.directory
          && !(builtins.elem cfg.directory [ "/" "/tmp" "/var" "/var/lib" "/home" ]);
        message = "services.restoreService.directory must be a dedicated absolute directory, not a common system root.";
      }
      {
        assertion = !(lib.hasPrefix "/nix/" cfg.directory)
          && !(lib.hasPrefix "/proc/" cfg.directory)
          && !(lib.hasPrefix "/sys/" cfg.directory)
          && !(lib.hasPrefix "/dev/" cfg.directory)
          && !(lib.hasPrefix "/run/" cfg.directory);
        message = "services.restoreService.directory must be on a writable regular filesystem.";
      }
    ];

    systemd.services.backuper-restore = {
      description = "On-demand Duplicity restore into an empty local directory";
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      # Deliberately no wantedBy or timer: manual execution only.
      path = [ pkgs.gnupg pkgs.cacert ];
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        Group = "root";
        EnvironmentFile = cfg.secretFile;
        ExecStart = restoreScript;
        UMask = "0077";
        PrivateTmp = true;
      };
    };
  };
}
