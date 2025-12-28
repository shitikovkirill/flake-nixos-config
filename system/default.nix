{
  nixpkgs.config.allowUnfree = true;
  imports = [ ./users ./time.nix ];
}
