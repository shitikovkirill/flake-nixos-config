{ lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ torrential flood ];
}
