{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }: {
    nixosConfigurations.asus-n56vj = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        /etc/nixos/configuration.nix
        home-manager.nixosModules.home-manager
        ./development
        { home-manager.users.kirill.home.stateVersion = "25.11"; }
      ];
      #./mashine/asus-n56vj ./system ./desctop/xfce.nix ./data ];
    };
  };
}
