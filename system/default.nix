{
  nixpkgs.config.allowUnfree = true;

  time.timeZone = "Europe/Prague";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  imports = [
    ./dev-server-config.nix
    ./users
    ./data
    ./aliases.nix
  ];
}
