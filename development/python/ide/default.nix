{ pkgs, ... }:

let
  script = import ../../common/tools/reset-jetbrains.nix { writeShellScriptBin = pkgs.writeShellScriptBin; };
in
{
  environment.systemPackages = with pkgs; [
    jetbrains.pycharm
    (script.reset "PyCharm")
  ];
}
