# Runs dynamically-linked binaries built for generic glibc Linux as-is,
# instead of NixOS's stub-ld placeholder rejecting them outright. Hits
# pip-installed tool binaries that pre-commit sets up in its own venvs
# (ruff, uv) and compiled Python extensions that dlopen system libs (e.g.
# SQLAlchemy's greenlet needing libstdc++.so.6).
{ pkgs, ... }:
{
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
  ];
}
