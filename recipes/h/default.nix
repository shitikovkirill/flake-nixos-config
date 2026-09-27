{ config, pkgs, ... }:

let
  cfg = config.custom.devServerConfig;
  codePath = cfg.codePath;
  hInit = ''
    eval "$(h --setup ${codePath})"
  '';
in {
  environment.systemPackages = with pkgs; [ h ];

  programs.zsh.shellInit = hInit;
  programs.bash.interactiveShellInit = hInit;
}
