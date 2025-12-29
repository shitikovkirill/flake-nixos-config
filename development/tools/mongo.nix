{ lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ robo3t mongodb-compass ];
}

