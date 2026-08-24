{ lib, pkgs, ... }:

let
  snx = pkgs.callPackage ./snx {};
in
{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    openssl
    nssTools
    xterm
  ];

  security.wrappers.snx = {
    source = "${snx}/libexec/snx";

    owner = "root";
    group = "root";

    setuid = true;
  };

  systemd.tmpfiles.rules = [
    "d /etc/snx 0700 root root -"
    "d /etc/snx/tmp 0700 root root -"
  ];
}
