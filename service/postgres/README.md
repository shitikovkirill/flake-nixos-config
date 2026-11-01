# Postgres module

## Usage

```nix
{ config, pkgs, ... }:
{
  imports = [ ../../service/postgres ];

  services.devPostgres = {
    enable = true;
    users = [
      {
        user = "vtb";
        passwordFile = config.sops.secrets.postgres_vtb_password.path;
        database = "vtb";
      }
    ];
    authentication = [
      "host all all 192.168.88.0/24 md5"
    ];
  };
}
```

`passwordFile` points to a file containing the plain-text password — in
practice a [sops-nix](../../docs/pages/server/secrets.md) secret path, never a
literal string. See [`profiles/service/pg.nix`](../../profiles/service/pg.nix)
for a complete example, and [Secrets (sops-nix)](../../docs/pages/server/secrets.md)
for how to add or edit the underlying secret.

## Options

| Option           | Type              | Default              | Description                                    |
| ---------------- | ----------------- | -------------------- | ----------------------------------------------- |
| `enable`         | `bool`            | `false`               | Enable the Postgres database.                   |
| `dataPath`       | `path`            | `/var/lib/postgres`   | PostgreSQL data directory.                      |
| `users`          | `list of submodule` | `[ ]`               | Users to ensure, each with `user`, `passwordFile`, `database`. |
| `authentication` | `list of str`     | `[ ]`                 | Additional `pg_hba.conf`-style authentication rules. |
