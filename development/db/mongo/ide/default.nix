{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    mongodb-compass
    robo3t
  ];
}
