# Baseline dev tooling every dev host should list explicitly (no implicit
# sharedModules inclusion — see the other profiles/ files for the same rule).
{
  imports = [
    ../development/common/bash.nix
    ../development/common/git
    ../development/common/direnv
    ../development/common/h
    ../development/common/ide/client.nix
    ../development/common/ai
    ../development/common/network
  ];
}
