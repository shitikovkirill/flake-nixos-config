{
  # Pinned to a specific commit (not `master`) so evaluation is pure and
  # reproducible. Bump the rev/sha256 pair to pick up upstream updates:
  #   nix-prefetch-url --unpack https://github.com/nix-community/nixos-vscode-server/archive/<rev>.tar.gz
  # See docs/pages/development/development.md for usage (auto-fix-vscode-server.service).
  imports = [
    (fetchTarball {
      url = "https://github.com/nix-community/nixos-vscode-server/archive/2f984dfbe7e5271b5c413d3e734374cc1306c921.tar.gz";
      sha256 = "179gqv45mby7wxdmrjmk8qqfgxh9316x2l9dkcvmmqrp9i4w5qfs";
    })
  ];

  services.vscode-server.enable = true;
}
