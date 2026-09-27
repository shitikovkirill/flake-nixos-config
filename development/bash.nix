{
  config,
  lib,
  pkgs,
  ...
}:

let
  userNames = map (u: u.name) config.services.systemUsers.users;
in
{
  home-manager.users = lib.genAttrs userNames (name: {
    programs.bash = {
      enableCompletion = true;
      historySize = 10000;
      historyFileSize = 10000;
    };
  });

  environment.systemPackages = with pkgs; [ shellcheck ];
}
