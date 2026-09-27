{ lib, pkgs, ... }:

{
  imports = [
    ./apps/social.nix
    ./apps/browser.nix
    ./apps/media.nix
    # ./apps/games.nix
    # ./apps/torrents.nix
  ];
}
