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
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      docs,
      sops-nix,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      rpiSystem = "aarch64-linux";

      # Modules shared by every variant of every host. Dev/server package
      # sets are NOT here — each host opts into the profiles/ it wants.
      sharedModules = [
        home-manager.nixosModules.home-manager
        (
          { config, lib, ... }:
          {
            home-manager.users = lib.genAttrs (map (u: u.name) config.services.systemUsers.users) (name: {
              home.stateVersion = lib.mkDefault "26.05";
            });
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

          sops-nix.nixosModules.sops
          ./secrets/secrets.nix

          ./server/docker-registry
          ./profiles/server-plain.nix
          # ECS Anywhere — registers this host as an external ECS container
          # instance; toggled via services.ecsAnywhere.enable in server.nix.
          ./server/ecs-anywhere
          # VS Code Remote-SSH server support — useful for a headless box
          # you connect to remotely, not enabled by default in profiles/.
          ./development/common/ide/server

          ./profiles/service/minio.nix
          ./profiles/service/pg.nix
          ./profiles/service/rabbitmq.nix
          ./profiles/service/mailpit.nix
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

      nixosConfigurations.rpi4 = nixpkgs.lib.nixosSystem {
        system = rpiSystem;
        specialArgs = { inherit inputs; };
        modules = sharedModules ++ [
          ./hosts/rpi4/hardware-configuration.nix
          ./hosts/rpi4/common.nix
          ./hosts/rpi4/storage.nix
          ./profiles/micro-dev.nix
          ./profiles/service/syncthing.nix
        ];
      };
    };
}
