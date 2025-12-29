{ lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ vlc vokoscreen ];
}
