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

      # Modules shared by every variant of every host. Dev/server package
      # sets are NOT here — each host opts into the profiles/ it wants.
      sharedModules = [
        home-manager.nixosModules.home-manager
        (
          { config, lib, ... }:
          {
            home-manager.users = lib.genAttrs (map (u: u.name) config.services.systemUsers.users) (
              name: {
                home.stateVersion = lib.mkDefault "26.05";
              }
            );
          }
        )
        ./server/pkgs
        ./system
      ];
    in
    {
      # Same physical laptop, two roles: pick one per `nixos-rebuild switch --flake .#<name>`.
      # Dev-profile toggles live in hosts/<name>/profiles.nix — comment/uncomment
      # lines there per host instead of editing this file.
      nixosConfigurations.asus-n56vj-desktop = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = sharedModules ++ [
          ./hosts/asus-n56vj/hardware-configuration.nix
          ./hosts/asus-n56vj/common.nix
          ./hosts/asus-n56vj/profiles.nix
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
          ./hosts/asus-n56vj/profiles.nix
          ./hosts/asus-n56vj/server.nix
          ./profiles/server-kube.nix
          ./profiles/server-plain.nix
          # VS Code Remote-SSH server support — useful for a headless box
          # you connect to remotely, not enabled by default in profiles/.
          ./development/common/ide/server
        ];
      };

      nixosConfigurations.asus-n580vn-desktop = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = sharedModules ++ [
          ./hosts/asus-n580vn/hardware-configuration.nix
          ./hosts/asus-n580vn/common.nix
          ./hosts/asus-n580vn/profiles.nix
          ./profiles/server-plain.nix
          ./hosts/asus-n580vn/desktop.nix
          ./desktop
        ];
      };
    };
}
