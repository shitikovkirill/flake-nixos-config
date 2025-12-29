{ config, pkgs, ... }:

let
  script = import ./reset-jetbrains.nix {
    writeShellScriptBin = pkgs.writeShellScriptBin;
  };
in {
  environment.systemPackages = with pkgs; [
    jetbrains.pycharm-professional
    jetbrains.datagrip
    jetbrains.goland
    jetbrains.webstorm

    (script.reset "WebStorm")
    (script.reset "DataGrip")
    (script.reset "PyCharm")
    (script.reset "RubyMine")
    (script.reset "PhpStorm")
    (script.reset "GoLand")
  ];
}
