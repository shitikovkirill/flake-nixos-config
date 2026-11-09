# Independent Duplicity backup and restore NixOS modules

Two independent modules share non-service-specific option definitions and validation helpers:

- `backuperService/` — scheduled Duplicity backups plus optional PostgreSQL dumps.
- `restoreService/` — manual restore of Duplicity backup content into an empty local directory.
- `common/` — shared endpoint options (`target`, `secretFile`) and assertions. This is **not** a NixOS module.
- `default.nix` — convenient import of both modules (neither is enabled automatically).

## Only restore (without backuperService installed)

```nix
{ config, ... }: {
  imports = [ ./nixos-duplicity-services/restoreService ];

  sops.secrets.duplicity = {
    sopsFile = ./secrets/backuper.env;
    format = "dotenv";
    mode = "0400";
  };

  services.restoreService = {
    enable = true;
    target = "boto3+s3://my-backup-bucket/rpi4";
    secretFile = config.sops.secrets.duplicity.path;
    directory = "/var/lib/backuper/restore";
    time = null;
  };
}
```

You must import the `sops-nix` NixOS module separately for `sops.secrets` to work.
For local restoration, the runtime file can instead be `/etc/backuper/duplicity.env` (outside the Nix store).

After `nixos-rebuild switch`, manually run:

```sh
sudo systemctl start backuper-restore.service
sudo journalctl -u backuper-restore.service -n 100 --no-pager
sudo ls -la /var/lib/backuper/restore
```

The service **restores decrypted backup contents**, not merely the raw encrypted chunks from S3. It will not automatically restore a PostgreSQL database. Choose a *different empty directory* or safely remove an earlier restore before running again.

## Only backup

```nix
{ config, ... }: {
  imports = [ ./nixos-duplicity-services/backuperService ];

  services.backuperService = {
    enable = true;
    databases = [ "vaultwarden" ];
    include = [ "/var/lib/vaultwarden" ];
    target = "boto3+s3://my-backup-bucket/rpi4";
    secretFile = config.sops.secrets.duplicity.path;
    frequency = "*-*-* 03:00:00";
    fullIfOlderThan = "1M";
    maxAge = "2M";
  };
}
```

## Both services

Import `./nixos-duplicity-services` or import both submodules individually. They have independent `enable`, `target`, `secretFile` options. They may point to the same bucket and the same SOPS secret, but this is not required.

```nix
services.restoreService = {
  enable = true;
  target = config.services.backuperService.target;
  secretFile = config.services.backuperService.secretFile;
  directory = "/var/lib/backuper/restore";
};
```

## Expected secret file (before encryption)

```dotenv
PASSPHRASE=strong-duplicity-passphrase
AWS_ACCESS_KEY_ID=example
AWS_SECRET_ACCESS_KEY=example
AWS_DEFAULT_REGION=eu-central-1
```

Use SOPS to encrypt the file before committing; never commit plaintext credentials.
Ensure that decryption keys are available to sops-nix on the target machine.

## Notes

- Restore is a manually invoked `oneshot` systemd service; no `wantedBy` or timer.
- It refuses nonempty destinations and symlink destinations.
- `services.restoreService` does **not** require or reference `services.backuperService`, `services.duplicity`, `services.postgresql`, or `services.postgresqlBackup`.
- Both services currently use the Duplicity executable from the system `pkgs` set.
- The backup module uses the built-in nixpkgs Duplicity and PostgreSQL backup modules; confirm service timing/dump naming for your pinned nixpkgs revision.
- No successful Nix evaluation or actual AWS restore was run in the generation environment. Test on a nonproduction host and verify restore integrity.
