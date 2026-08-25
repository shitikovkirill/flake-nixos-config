{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    claude-code
    claude-monitor
  ];
}
