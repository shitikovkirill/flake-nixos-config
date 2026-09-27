{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./bash.nix
    ./git
    ./direnv
    ./nix
    ./h
    ./ide.nix
    ./ai
    # ./vs_code # VS Code Remote-SSH server support (nixos-vscode-server)
    # ./electronics.nix
    # ./tools
    # ./python
    # ./go.nix
    # ./database
  ];
}
