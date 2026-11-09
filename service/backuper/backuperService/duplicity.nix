{ config, lib, pkgs, ... }:
let
  cfg = config.services.backuperService;
  common = import ../common/default.nix { inherit lib; };
  helper = import ./helpers.nix { inherit lib cfg; };
in
{
  config = lib.mkIf cfg.enable {
    assertions = common.helpers.endpointAssertions "services.backuperService" cfg ++ [
      {
        assertion = cfg.postgresql.enable || cfg.include != [ ];
        message = "services.backuperService: enable PostgreSQL backups or list at least one include path.";
      }
      {
        assertion = lib.all (p: lib.hasPrefix "/" p) cfg.include;
        message = "services.backuperService.include paths must be absolute.";
      }
      {
        assertion = lib.hasPrefix "/" cfg.postgresql.location;
        message = "services.backuperService.postgresql.location must be absolute.";
      }
      {
        assertion = lib.all (db: builtins.match "[A-Za-z_][A-Za-z0-9_]*" db != null) cfg.databases;
        message = "services.backuperService.databases must contain simple PostgreSQL identifiers.";
      }
      {
        assertion = !cfg.postgresql.enable || !(lib.any (p:
          p == cfg.postgresql.location
          || lib.hasPrefix "${p}/" cfg.postgresql.location
          || lib.hasPrefix "${cfg.postgresql.location}/" p
        ) cfg.include);
        message = "services.backuperService.include must not overlap PostgreSQL dump directory.";
      }
    ];

    services.duplicity = {
      enable = true;
      root = "/";
      excludeFileList = lib.mkIf cfg.postgresql.enable (
        pkgs.writeText "backuper-postgresql-exclusions" ''
          - ${cfg.postgresql.location}/*.prev.sql.gz
          - ${cfg.postgresql.location}/*.in-progress.sql.gz
        ''
      );
      include = helper.selectedPaths;
      exclude = [ "**" ];
      targetUrl = cfg.target;
      secretFile = cfg.secretFile;
      frequency = cfg.frequency;
      fullIfOlderThan = cfg.fullIfOlderThan;
      cleanup.maxAge = cfg.maxAge;
      extraFlags = cfg.extraFlags;
    };
  };
}
