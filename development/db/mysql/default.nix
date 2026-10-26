{ pkgs, ... }:

{
  # mariadb is the full server+client package — no separate client-only
  # attribute exists in nixpkgs, so this pulls in more than just `mysql`.
  environment.systemPackages = with pkgs; [ mariadb ];
}
