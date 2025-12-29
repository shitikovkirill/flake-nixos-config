with import <nixpkgs> { };

let
  appName = "JetBrainsResetTrail";
  description = "Reset IDE";

  script =
    import ./reset-jetbrains.nix { writeShellScriptBin = writeShellScriptBin; };

in mkShell rec {
  name = appName;

  buildInputs = [
    (script.reset "WebStorm")
    (script.reset "DataGrip")
    (script.reset "PyCharm")
    (script.reset "RubyMine")
    (script.reset "PhpStorm")
    (script.reset "GoLand")
  ];

  meta = with lib; {
    inherit description;
    license = licenses.lgpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ shitikovkirill ];
  };
}
