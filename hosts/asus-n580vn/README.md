# asus-n580vn

ASUS VivoBook Pro N580VN-FY062

Migrated from a pre-flake `configuration.nix` originally installed under
NixOS 23.11 (hence `system.stateVersion`/`home-manager` stateVersion staying
at `"23.11"` in `common.nix` — see the comments there). Single role so far:
`asus-n580vn-desktop` (GRUB + os-prober, KDE Plasma, Bluetooth).

Still dual-boots a real Manjaro install (`/dev/sdb3`) — GRUB stays, not
systemd-boot, so `useOSProber` keeps surfacing it in the boot menu. See
`common.nix` for details.

See [Architecture](../../docs/pages/architecture.md) for how this fits into
the rest of the repo, and
[Development Environment](../../docs/pages/development/development.md) for
the profile list this host imports in `flake.nix`.
