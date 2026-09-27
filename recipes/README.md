# Recipes

Reusable NixOS/home-manager modules originally ported over from
[`NixOsDevConfig`](https://github.com/shitikovkirill/NixOsDevConfig), the
universal "recipes" repo used to bootstrap dev tooling on any machine.

**This folder is intentionally not imported by `flake.nix` or any
`default.nix` in this repo.** It exists as a reviewed reference — pull
individual recipes into a real config (here or elsewhere) as needed, via
`custom.devServerConfig.user`/`codePath`.

`git/`, `h/`, `direnv/`, and `nix/` were removed after comparison showed
they'd become pure duplicates of this repo's own `development/git`,
`development/h`, `development/direnv`, and `development/nix` (which are
already parameterized via `custom.devServerConfig` and slightly ahead —
e.g. `development/nix` has extra aliases, `development/git` also installs
`gitg`). Use those instead.

## Contents

| Recipe | What it sets up |
|--------|------------------|
| `vs_code/` | VS Code Remote Server support via the `nixos-vscode-server` community module |
| `users/` | `users.mutableUsers = false` + a templated MOTD |
| `aliases.nix` | misc shell aliases (chown fixups, `grep`-from-cwd) |
| `default.nix` | declares `custom.devServerConfig.{user,codePath}` and wires the above together |

## Compatibility notes (as of nixos-26.05)

`NixOsDevConfig` targets an older nixpkgs, so each recipe was re-checked
against this repo's pinned nixpkgs before being copied over:

- **`vs_code/`**: pulls `nixos-vscode-server` from the `master` branch
  tarball — unpinned. It still evaluates and builds fine today, but pin it
  to a commit/tag before depending on it long-term.
- **`users/`, `aliases.nix`**: no changes needed; all referenced options
  (`users.motd`, etc.) still exist as-is.

This was verified by evaluating and building a throwaway `nixosSystem`
that imported `./recipes` directly (not part of this repo's actual
configuration) — `system.build.toplevel` built successfully.
