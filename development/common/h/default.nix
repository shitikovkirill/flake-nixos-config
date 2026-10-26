{ config, pkgs, ... }:

let
  codePath = config.custom.devServerConfig.codePath;
  hInit = ''
    eval "$(h --setup ${codePath})"
  '';
in
{
  environment.systemPackages = with pkgs; [ h ];

  programs.zsh.shellInit = hInit;
  programs.bash.interactiveShellInit = hInit;
}
