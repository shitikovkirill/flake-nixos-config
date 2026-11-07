{ pkgs, ... }:

{
  imports = [
    ../development/common/git
    ../development/common/network
  ];

  environment.systemPackages = with pkgs; [
    shellcheck
  ];
}
