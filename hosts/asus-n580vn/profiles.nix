# Toggle this host's dev tooling by commenting/uncommenting the lines below
# — nothing else needs to change. Only minimal-dev is on by default; enable
# whatever else this machine actually needs to work with.
{
  imports = [
    ../../profiles/minimal-dev.nix
    # ../../profiles/nix-dev.nix
    # ../../profiles/python-dev.nix
    # ../../profiles/go-dev.nix
    # ../../profiles/js-dev.nix
    # ../../profiles/db-dev.nix
    # ../../profiles/ide-tools.nix
    # ../../profiles/electronics-dev.nix
  ];
}
