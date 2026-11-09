{ lib, ... }:
let
  common = import ../common/default.nix { inherit lib; };
  inherit (lib) mkOption types;
in
{
  options.services.restoreService = common.options // {
    enable = lib.mkEnableOption "independent on-demand Duplicity restore service";

    directory = mkOption {
      type = types.str;
      default = "/var/lib/backuper/restore";
      example = "/srv/restored-files";
      description = "Empty local destination directory for restored files. Refuses nonempty paths.";
    };

    time = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "7D";
      description = "Restore point (e.g. 7D or a timestamp); null restores latest.";
    };
  };
}
