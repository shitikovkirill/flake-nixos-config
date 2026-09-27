{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    docs = {
      url = "path:./docs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      docs,
      ...
    }@inputs:
    let
      system = "x86_64-linux";

      # Modules shared by every variant of every host.
      sharedModules = [
        home-manager.nixosModules.home-manager
        (
          { config, lib, ... }:
          {
            home-manager.users = lib.genAttrs (map (u: u.name) config.services.systemUsers.users) (
              name: {
                home.stateVersion = "26.05";
              }
            );
          }
        )
        ./development
        ./server/pkgs
        ./system
      ];
    in
    {
      # Same physical laptop, two roles: pick one per `nixos-rebuild switch --flake .#<name>`.
      nixosConfigurations.asus-n56vj-desktop = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = sharedModules ++ [
          ./hosts/asus-n56vj/hardware-configuration.nix
          ./hosts/asus-n56vj/common.nix
          ./hosts/asus-n56vj/desktop.nix
          ./desktop
        ];
      };

      nixosConfigurations.asus-n56vj-server = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = sharedModules ++ [
          ./hosts/asus-n56vj/hardware-configuration.nix
          ./hosts/asus-n56vj/common.nix
          ./hosts/asus-n56vj/server.nix
          ./server
        ];
      };
    };
}
