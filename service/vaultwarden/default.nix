{ ... }:

{
  imports = [
    ./options.nix
    ./packages.nix
    ./users.nix
    ./postgresql.nix
    ./restore.nix
    ./service.nix
    ./firewall.nix
  ];
}
