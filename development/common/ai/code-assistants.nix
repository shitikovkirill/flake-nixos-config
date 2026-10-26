{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    aider-chat # AI pair programming in terminal
    continue # VS Code extension for AI coding (if used)
  ];
}
