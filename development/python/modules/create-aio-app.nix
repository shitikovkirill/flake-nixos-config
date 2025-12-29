{ lib, pkgs, buildPythonPackage, fetchPypi, pythonPackages, cookiecutter }:
buildPythonPackage rec {
  pname = "create-aio-app";
  version = "0.0.9";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1ns6yj1xjdnq1m59p7y2f45bic1f1px0xvi9yzj0pny8akwhf9zb";
  };

  buildInputs = with pythonPackages; [ setuptools-scm-git-archive ];
  propagatedBuildInputs = [ pythonPackages.click cookiecutter ];

  doCheck = false;
  preBuild = "echo 'import setuptools; setuptools.setup()' > setup.py";

  meta = {
    homepage = "https://github.com/aio-libs/create-aio-app";
    description = "Create aio app";
  };
}
