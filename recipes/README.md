# Recipes

Reusable NixOS/home-manager modules ported over from
[`NixOsDevConfig`](https://github.com/shitikovkirill/NixOsDevConfig), the
universal "recipes" repo used to bootstrap dev tooling on any machine.

**This folder is intentionally not imported by `flake.nix` or any
`default.nix` in this repo.** It exists as a reviewed, up-to-date reference —
pull individual recipes into a real config (here or elsewhere) as needed,
via `custom.devServerConfig.user`/`codePath`.

## Contents

| Recipe | What it sets up |
|--------|------------------|
| `git/` | git + git-crypt + pre-commit, home-manager `programs.git`, merge-cleanup aliases |
| `h/` | [`h`](https://github.com/zimbatm/h) fast project navigation, wired to `codePath` |
| `nix/` | niv, nox, nix-info, nix-index, nixfmt, nix-prefetch-git, a `containers_rm` helper |
| `direnv/` | direnv + nix-direnv, shell hooks, a `.direnvrc` with `nix-profile`/`layout_golang`/`layout_poetry` |
| `vs_code/` | VS Code Remote Server support via the `nixos-vscode-server` community module |
| `users/` | `users.mutableUsers = false` + a templated MOTD |
| `aliases.nix` | misc shell aliases (nix GC, chown fixups, disk usage, etc.) |
| `default.nix` | wires all of the above together behind `custom.devServerConfig.{user,codePath}` |

## Compatibility notes (as of nixos-26.05)

`NixOsDevConfig` targets an older nixpkgs, so each recipe was re-checked
against this repo's pinned nixpkgs before being copied over:

- **`nix/`**: `nixfmt-classic` no longer exists in nixpkgs — replaced with
  `nixfmt` (same fix already applied in this repo's own
  `development/nix`).
- **`git/`**: the original recipe used the old flat
  `programs.git.{userName,userEmail,extraConfig,aliases}` home-manager
  options. Rewritten to the current ini-style `programs.git.settings`
  schema, matching this repo's already-working `development/git` module.
- **`vs_code/`**: pulls `nixos-vscode-server` from the `master` branch
  tarball — unpinned. It still evaluates and builds fine today, but pin it
  to a commit/tag before depending on it long-term.
- **`h/`, `direnv/`, `users/`, `aliases.nix`**: no changes needed; all
  referenced packages/options (`h`, `direnv`, `nix-direnv`, `users.motd`,
  etc.) still exist as-is.

All of the above was verified by evaluating and building a throwaway
`nixosSystem` that imports `./recipes` directly (not part of this repo's
actual configuration) — `nixos-system-test-*.drv` built successfully,
producing a working `system.build.toplevel`.
