{ lib, pkgs, ... }:

{
  imports = [ ./social.nix ./browser.nix ./media.nix ];  # ./games.nix ./torrents.nix
}
