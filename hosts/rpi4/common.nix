{ config, lib, pkgs, ... }:

let
  hostName = "rpi4";
  lanIface = "end0";
  lanAddr = "192.168.88.221";
  lanPrefix = 24;
  gateway = "192.168.88.1";
  dns = [ "172.17.0.2" "192.168.88.1" ];
in
{
  imports = [ ../../system ];
  # ---------- Boot ----------
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.loader.generic-extlinux-compatible.configurationLimit = 10;

  boot.kernelPackages = pkgs.linuxPackages;

  hardware.enableRedistributableFirmware = true;

  fileSystems."/".options = [ "noatime" ];

  # ---------- Network: static IPv4 on Ethernet ----------
  networking.hostName = hostName;
  networking.useDHCP = false;
  networking.interfaces.${lanIface} = {
    useDHCP = false;
    ipv4.addresses = [ { address = lanAddr; prefixLength = lanPrefix; } ];
  };
  networking.defaultGateway = { address = gateway; interface = lanIface; };
  networking.nameservers = dns;

  networking.firewall.enable = true;

  # ---------- Locale ----------
  i18n.defaultLocale = "en_US.UTF-8";

  security.sudo.wheelNeedsPassword = true;

  # ---------- SSH ----------
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  # ---------- Nix ----------
  nix.settings = {
    trusted-users = [ "root" "kirill" ];
    auto-optimise-store = true;
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # ---------- Resource tuning for a small board ----------
  zramSwap.enable = true;
  services.journald.extraConfig = ''
    SystemMaxUse=200M
  '';

  # ---------- Packages ----------
  environment.systemPackages = with pkgs; [
    htop
    curl
  ];

  system.stateVersion = "25.11";
}
