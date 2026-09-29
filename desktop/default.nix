{ lib, pkgs, ... }:

{
  imports = [
    ./environments/plasma6.nix
    ./audio.nix
    ./apps/social.nix
    ./apps/browser.nix
    ./apps/media.nix
    # ./apps/games.nix
    # ./apps/torrents.nix
  ];
}
