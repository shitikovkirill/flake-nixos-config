{
  # NOTE: this pulls the community module straight from the `master` branch
  # tarball — unpinned, so it can break silently when upstream changes.
  # Pin to a specific commit/tag before relying on this in a real config.
  # See docs/pages/development.md for usage (auto-fix-vscode-server.service).
  imports = [
    (fetchTarball
      "https://github.com/nix-community/nixos-vscode-server/tarball/master")
  ];

  services.vscode-server.enable = true;
}
