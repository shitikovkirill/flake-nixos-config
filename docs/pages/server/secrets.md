# Secrets (sops-nix)

Service passwords and other credentials used by `profiles/service/*.nix` are not
stored in plain text in the repository. They are encrypted with
[sops-nix](https://github.com/Mic92/sops-nix) and decrypted on the target host
at activation time, using that host's SSH host key — no separate key file to
manage or keep safe.

## How it works

- `.sops.yaml` at the repo root lists the age public key(s) allowed to decrypt
  each `secrets/*.yaml` file. The key currently configured is derived from
  `asus-n56vj`'s `/etc/ssh/ssh_host_ed25519_key`.
- `secrets/<name>.yaml` files hold the encrypted values (safe to commit).
- `secrets/secrets.nix` declares `sops.defaultSopsFile` and each
  `sops.secrets.<key>` entry (owner/group/mode for the decrypted file).
- At boot/activation, `sops-nix.service` decrypts the configured file into
  `/run/secrets/<key>`, readable only by the owner configured in
  `secrets/secrets.nix`.
- Modules that need a secret take a `passwordFile` option (a path) instead of
  a `password` string, and read `config.sops.secrets.<key>.path` from the
  profile that wires them up — see `profiles/service/pg.nix`.

```
┌────────────────────┐   encrypted    ┌──────────────────┐
│ secrets/pg.yaml     │ ─────────────▶│ sops-nix.service  │
│ (committed to git)  │                │ (on target host)  │
└────────────────────┘                └─────────┬────────┘
                                                  │ decrypts using
                                                  │ /etc/ssh/ssh_host_ed25519_key
                                                  ▼
                                      /run/secrets/<key>  (root/owner only)
                                                  │
                                                  ▼
                                    consumed via `passwordFile` option
```

## Editing secrets

Run on the host whose SSH host key is a recipient in `.sops.yaml`
(`nix` is enough, no need to install `sops` system-wide):

```sh
nix run nixpkgs#sops -- secrets/pg.yaml
```

This opens the decrypted file in `$EDITOR`, re-encrypting on save.

## Adding a new secret

1. Add the key to the relevant `secrets/<name>.yaml` (create the file with
   `nix run nixpkgs#sops -- secrets/<name>.yaml` if it doesn't exist yet —
   `.sops.yaml`'s `path_regex` already covers `secrets/*.yaml`).
2. Declare it in `secrets/secrets.nix`:
   ```nix
   sops.secrets.my_new_secret = {
     owner = "some-service-user"; # defaults to root
   };
   ```
3. Reference `config.sops.secrets.my_new_secret.path` from the profile that
   needs it, and add a `passwordFile`/`*File` option to the consuming module
   if it currently takes the value as a plain string.

## Adding a new host as a recipient

Get the host's age public key from its SSH host key (no key generation needed):

```sh
nix run nixpkgs#ssh-to-age -- -i /etc/ssh/ssh_host_ed25519_key.pub
```

Add the resulting `age1...` key to `.sops.yaml`, then re-encrypt existing
secret files so the new host can decrypt them too:

```sh
nix run nixpkgs#sops -- updatekeys secrets/pg.yaml
```
