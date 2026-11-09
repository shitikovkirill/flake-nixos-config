{ ... }:
{
  imports = [
    ./options.nix
    ./postgresql.nix
    ./duplicity.nix
    ./systemd.nix
  ];
}
