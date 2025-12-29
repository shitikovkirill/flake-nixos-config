{ lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    firefox
    chromium
    # w3m
    # filezilla
    # opera
  ];
}
