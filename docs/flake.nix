{
  description = "flake-nixos-config documentation with Sphinx";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          name = "docs-dev";
          buildInputs = with pkgs; [
            (python3.withPackages (ps: with ps; [
              sphinx
              sphinx-rtd-theme
              myst-parser
              furo
            ]))
            gnumake
          ];
        };

        packages.default = pkgs.stdenv.mkDerivation {
          name = "flake-nixos-config-docs";
          src = ./.;
          buildInputs = with pkgs; [
            (python3.withPackages (ps: with ps; [
              sphinx
              sphinx-rtd-theme
              myst-parser
              furo
            ]))
            gnumake
          ];

          buildPhase = ''
            make html
          '';

          installPhase = ''
            mkdir -p $out
            cp -r _build/html/* $out/
          '';
        };
      }
    );
}
