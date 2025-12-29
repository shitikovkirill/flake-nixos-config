{ config, lib, pkgs, ... }:

{
  home-manager.users.kirill = {
    programs.bash = {
      enableCompletion = true;
      historySize = 10000;
      historyFileSize = 10000;
    };
  };

  environment.systemPackages = with pkgs; [ shellcheck ];
}
