# Pgadmin module

## Usage

```nix
{ config, pkgs, ... }:
{
  imports = [ ../../service/pgadmin ];

  services.pgadminService = {
    enable = true;
    domain = "db.home";
    email = "sh.kiruh@gmail.com";
    passwordFile = config.sops.secrets.pgadmin_password.path;
  };
}
```

`passwordFile` points to a file containing the plain-text initial admin
password — in practice a [sops-nix](../../docs/pages/server/secrets.md)
secret path, never a literal string. See
[`profiles/service/pg.nix`](../../profiles/service/pg.nix) for a complete
example, and [Secrets (sops-nix)](../../docs/pages/server/secrets.md) for how
to add or edit the underlying secret.

## Options

| Option         | Type     | Default | Description                              |
| -------------- | -------- | ------- | ----------------------------------------- |
| `enable`       | `bool`   | `false` | Enable pgadmin.                           |
| `https`        | `bool`   | `false` | Enable HTTPS.                             |
| `domain`       | `str`    | —       | Domain pgadmin is served on.              |
| `email`        | `str`    | —       | Initial admin email.                      |
| `passwordFile` | `path`   | —       | Path to a file containing the initial admin password. |
