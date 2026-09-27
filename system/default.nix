{
  nixpkgs.config.allowUnfree = true;
  imports = [
    ./dev-server-config.nix
    ./users
    ./aliases.nix
  ];
}
