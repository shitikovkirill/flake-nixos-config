# Host-level settings shared by every variant of this machine. GUI-only bits
# live in ./desktop.nix.
{ config, pkgs, ... }:

{
  # Switched from GRUB+os-prober (old dual-boot setup) to systemd-boot.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "asus-n580vn";
  networking.networkmanager.enable = true;

  # Machine was originally installed under NixOS 23.11 — do not bump this,
  # see the stateVersion docs in configuration.nix(5).
  system.stateVersion = "23.11";

  # kirill's home-manager profile here started under 23.11 too — don't bump
  # it to the flake-wide default, same reasoning as system.stateVersion above.
  home-manager.users.kirill.home.stateVersion = "23.11";
}
