{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ arduino rpi-imager ];
}
