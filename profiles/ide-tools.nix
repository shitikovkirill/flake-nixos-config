# Cross-language tools that don't fit any single language profile.
# DataGrip moved to development/db/ide; Py/Go/JS Charm-family IDEs live
# under their own language's ide/ dir.
{ pkgs, ... }:

let
  script = import ../development/common/tools/reset-jetbrains.nix { writeShellScriptBin = pkgs.writeShellScriptBin; };
in
{
  environment.systemPackages = with pkgs; [
    bruno
    postman
    xmind
    (script.reset "RubyMine")
    (script.reset "PhpStorm")
  ];
}
