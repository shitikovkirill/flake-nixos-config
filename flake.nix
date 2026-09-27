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
    {
      nixosConfigurations.asus-n56vj = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          /etc/nixos/configuration.nix
          home-manager.nixosModules.home-manager
          { home-manager.users.kirill.home.stateVersion = "26.05"; }
          ./development
          ./server/pkgs
          ./system
          ./server
        ];
      };
    };
}
