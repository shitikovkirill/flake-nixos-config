{
  nixpkgs.config.allowUnfree = true;
  imports = [ ./users ./aliases.nix ];
}
