{ config, pkgs, lib, ... }:

let
  cfg = config.custom.devServerConfig;
  user = cfg.user;
in {
  environment.systemPackages = with pkgs; [ direnv nix-direnv ];

  programs = {
    bash.interactiveShellInit = ''
      if [ -x "$(command -v direnv)" ]; then
          eval "$(direnv hook bash)"
      fi
    '';
    zsh = lib.mkIf (config.programs.zsh.enable) {
      shellInit = ''
        if [ -x "$(command -v direnv)" ]; then
            eval "$(direnv hook zsh)"
        fi
      '';
    };
  };

  # nix options for derivations to persist garbage collection
  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  '';
  environment.pathsToLink = [ "/share/nix-direnv" ];

  home-manager.users.${user} = {
    home = { file.".direnvrc".source = ./direnvrc; };
  };
}
