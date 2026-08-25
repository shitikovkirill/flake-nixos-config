{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    aider-chat # AI pair programming в терминале
    continue # VS Code расширение для AI coding (если используется)
  ];
}
