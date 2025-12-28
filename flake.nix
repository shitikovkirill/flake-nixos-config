let
  users = import (data/users.nix);
in {
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

  outputs = { self, nixpkgs, ... }: {
    nixosConfigurations.asus-n56vj = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ 
        ./mashine/asus-n56vj
        ./system
        ./desctop/xfce.nix
        ./data/users.nix
      ];
    };

    services.systemUsers = {
      enable = true;
      inherit users;
    };

  };
}