{ lib, pkgs, buildPythonPackage, fetchPypi, pythonPackages }:

buildPythonPackage rec {
  pname = "setuptools_scm_git_archive";
  version = "1.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0qn08q5isa7dhl1m74xk14k53js19wqrazkkxsss2gxpi48gc9k0";
  };

  doCheck = false;

  propagatedBuildInputs = with pythonPackages; [ setuptools-scm ];

  meta = {
    homepage = "https://pypi.org/project/setuptools-scm/";
    description = ''
      setuptools_scm handles managing your Python package
              versions in SCM metadata instead of declaring them as the version
               argument or in a SCM managed file.'';
  };
}
