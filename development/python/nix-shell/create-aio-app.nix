with import <nixpkgs> { };

(let
  setuptools-scm-git-archive = python38.pkgs.buildPythonPackage rec {
    pname = "setuptools_scm_git_archive";
    version = "1.1";

    src = python38.pkgs.fetchPypi {
      inherit pname version;
      sha256 = "0qn08q5isa7dhl1m74xk14k53js19wqrazkkxsss2gxpi48gc9k0";
    };

    doCheck = false;

    propagatedBuildInputs = with python38.pkgs; [ setuptools-scm ];

    meta = {
      homepage = "https://pypi.org/project/setuptools-scm/";
      description = ''
        setuptools_scm handles managing your Python package
                versions in SCM metadata instead of declaring them as the version
                 argument or in a SCM managed file.'';
    };
  };

  myPythonPackages = python38Packages.override {
    overrides = self: super: {
      cookiecutter = super.cookiecutter.overrideAttrs (oldAttrs: rec {
        version = "1.7.0";
        src = python38.pkgs.fetchPypi {
          pname = oldAttrs.pname;
          inherit version;
          sha256 = "1bh4vf45q9nanmgwnw7m0gxirndih9yyz5s0y2xbnlbcqbhrg6a7";
        };
      });
    };
  };

  create-aio-app = python38.pkgs.buildPythonPackage rec {
    pname = "create-aio-app";
    version = "0.0.9";

    src = python38.pkgs.fetchPypi {
      inherit pname version;
      sha256 = "1ns6yj1xjdnq1m59p7y2f45bic1f1px0xvi9yzj0pny8akwhf9zb";
    };

    buildInputs = [ setuptools-scm-git-archive ];
    propagatedBuildInputs = with myPythonPackages; [ click cookiecutter ];

    doCheck = false;
    preBuild = "echo 'import setuptools; setuptools.setup()' > setup.py";

    meta = {
      homepage = "https://github.com/aio-libs/create-aio-app";
      description = "Create aio app";
    };
  };

in python38.withPackages (ps: [ create-aio-app ])).env
