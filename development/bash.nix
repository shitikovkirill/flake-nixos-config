{
  config,
  lib,
  pkgs,
  ...
}:

let
  user = config.custom.devServerConfig.user;
in
{
  home-manager.users.${user} = {
    programs.bash = {
      enableCompletion = true;
      historySize = 10000;
      historyFileSize = 10000;
    };
  };

  environment.systemPackages = with pkgs; [ shellcheck ];
}
