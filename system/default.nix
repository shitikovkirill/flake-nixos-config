{
  nixpkgs.config.allowUnfree = true;
  imports = [
    ./dev-server-config.nix
    ./users
    ./data
    ./aliases.nix
  ];
}
