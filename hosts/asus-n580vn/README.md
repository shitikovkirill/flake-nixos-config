# asus-n580vn

ASUS VivoBook Pro N580VN-FY062

Migrated from a pre-flake `configuration.nix` originally installed under
NixOS 23.11 (hence `system.stateVersion`/`home-manager` stateVersion staying
at `"23.11"` in `common.nix` — see the comments there). Single role so far:
`asus-n580vn-desktop` (systemd-boot, KDE Plasma, Bluetooth).

See [Architecture](../../docs/pages/architecture.md) for how this fits into
the rest of the repo, and
[Development Environment](../../docs/pages/development/development.md) for
the profile list this host imports in `flake.nix`.
