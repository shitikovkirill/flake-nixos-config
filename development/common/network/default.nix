# Local dev network access. ./hosts.nix is untracked (see .gitignore) and
# optional — copy hosts.nix.example if you need private /etc/hosts entries.
let
  hosts = import ./load-hosts.nix;
in
{
  networking.hosts = hosts;

  networking.firewall.allowedTCPPortRanges = [{
    from = 30000;
    to = 50000;
  }];
  networking.firewall.allowedUDPPortRanges = [{
    from = 30000;
    to = 50000;
  }];
}
