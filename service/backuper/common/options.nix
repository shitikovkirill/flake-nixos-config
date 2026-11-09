{ lib }:
{
  target = lib.mkOption {
    type = lib.types.str;
    example = "boto3+s3://my-backup-bucket/rpi4";
    description = "Duplicity backend URL (must not contain credentials).";
  };

  secretFile = lib.mkOption {
    type = lib.types.str;
    example = "/run/secrets/backuper";
    description = "Absolute runtime path to a systemd EnvironmentFile, e.g. from sops-nix. Never place credentials in the Nix store.";
  };
}
