# Host-level settings shared by every variant of this machine. GUI-only bits
# live in ./desktop.nix.
{ config, pkgs, ... }:

{
  # GRUB (not systemd-boot) — this machine still dual-boots a real, intact
  # Manjaro install (/dev/sdb3, EFI NVRAM entry "Manjaro"). useOSProber
  # surfaces it in the boot menu; switching to systemd-boot wouldn't delete
  # Manjaro but would lose that unified menu (systemd-boot has no os-prober
  # equivalent — Manjaro would only be reachable via the firmware's own
  # one-time boot-device picker, e.g. F12).
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    devices = [ "nodev" ];
    efiSupport = true;
    useOSProber = true;
  };

  networking.hostName = "asus-n580vn";
  networking.networkmanager.enable = true;

  # Machine was originally installed under NixOS 23.11 — do not bump this,
  # see the stateVersion docs in configuration.nix(5).
  system.stateVersion = "23.11";

  # kirill's home-manager profile here started under 23.11 too — don't bump
  # it to the flake-wide default, same reasoning as system.stateVersion above.
  home-manager.users.kirill.home.stateVersion = "23.11";
}
