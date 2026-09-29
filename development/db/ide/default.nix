{ pkgs, ... }:

let
  script = import ../../common/tools/reset-jetbrains.nix { writeShellScriptBin = pkgs.writeShellScriptBin; };
in
{
  environment.systemPackages = with pkgs; [
    dbeaver-bin
    jetbrains.datagrip
    (script.reset "DataGrip")
  ];
}
