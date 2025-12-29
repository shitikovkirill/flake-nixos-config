{ config, pkgs, ... }:

let
  hInit = ''
    eval "$(h --setup ~/Code)"
  '';
in {
  environment.systemPackages = with pkgs; [ h ];

  programs.zsh.shellInit = hInit;
  programs.bash.interactiveShellInit = hInit;
}
