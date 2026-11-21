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
    # vtb-python Telegram bot - nixosModules.default runs its app/worker/
    # local Telegram Bot API server as systemd services, built from its
    # own pinned nixpkgs (nixos-unstable), not this flake's nixpkgs -
    # deliberately NOT `inputs.nixpkgs.follows`-ed, since its uv2nix/
    # pyproject-nix build machinery is only verified against that pin.
    vtb-python = {
      url = "git+ssh://gitea@git.webwave.work/TelegramBot/vtb-python.git?ref=main";
    };
    # photo-archiver pipeline - nixosModules.default runs it as one
    # systemd service (every worker + publisher/loader in-process, see
    # app/main.py) + a migrate oneshot. Same reasoning as vtb-python
    # above: built from its own pinned nixpkgs/poetry2nix, deliberately
    # NOT followed here.
    photo-archiver = {
      url = "git+ssh://gitea@git.webwave.work/WebWave/photo-archiver.git?ref=main";
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
          ./secrets/asus-n56vj/secrets.nix

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

          # vtb-python Telegram bot - app/worker/local Bot API server as
          # systemd services. Depends on the pg.nix/rabbitmq.nix services
          # above (its own Postgres user + the local RabbitMQ guest account
          # aren't provisioned by this module itself). Still needs
          # `services.vtb-python.enable`/`environmentFile` set somewhere
          # (not yet - see hosts/asus-n56vj/server.nix).
          inputs.vtb-python.nixosModules.default

          # photo-archiver pipeline - one systemd unit (every worker +
          # publisher/loader) + a migrate oneshot. Depends on the
          # pg.nix/minio.nix services above (its own Postgres user is
          # already provisioned there; MinIO/AWS S3 source and target
          # buckets are not provisioned by this module itself). Still
          # needs `services.photo-archiver.enable`/environmentFile/
          # sourcesYaml/targetsYaml/credentialsYaml set somewhere (not yet
          # - see hosts/asus-n56vj/server.nix).
          inputs.photo-archiver.nixosModules.default
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
          ./hosts/rpi4/services.nix
          ./hosts/rpi4/vaultwarden.nix
          ./hosts/rpi4/pg.nix

          sops-nix.nixosModules.sops
          ./secrets/rpi4/backuper.nix
          ./secrets/rpi4/vaultwarden.nix

          ./profiles/micro-dev.nix
          ./profiles/service/syncthing.nix
          ./profiles/service/backuper.nix
        ];
      };

      devShells.${system}.default =
        nixpkgs.legacyPackages.${system}.mkShell {
          packages = with nixpkgs.legacyPackages.${system}; [
            sops
            age
            ssh-to-age
          ];
        };
    };
}
