{
  description = "flake-nixos-config documentation with Sphinx";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      sphinxEnv = pkgs.python3.withPackages (ps: with ps; [
        sphinx
        sphinx-rtd-theme
        myst-parser
        furo
      ]);
    in
    {
      packages.${system}.default = pkgs.stdenv.mkDerivation {
        name = "flake-nixos-config-docs";
        src = ./.;
        buildInputs = [ sphinxEnv pkgs.gnumake ];

        buildPhase = ''
          make html
        '';

        installPhase = ''
          mkdir -p $out
          cp -r _build/html/. $out/
        '';
      };

      devShells.${system}.default = pkgs.mkShell {
        name = "docs-dev";
        buildInputs = [ sphinxEnv pkgs.gnumake ];
      };
    };
}
