{
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  setuptools-dso,
  numpy,
  epicscorelibs,
  pvxslibs,
  cython,
  nose2,
  ply,
  lib,
  epnixLib,
}:
buildPythonPackage rec {
  pname = "p4p";
  version = "4.2.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "epics-base";
    repo = pname;
    tag = version;
    hash = "sha256-9STSSfao7RkAXJsdzx+nrvndx4tV4eE+olgTOZ0owX8=";
  };

  # Configure exists as a directory, which nix assumes it has to execute...
  dontConfigure = true;

  build-system = [ setuptools ];
  nativeBuildInputs = [
    setuptools-dso
    cython
  ];
  dependencies = [
    setuptools
    numpy
    epicscorelibs
    pvxslibs
  ];
  checkInputs = [
    nose2
    ply
  ];

  meta = {
    description = "Python bindings for the PVAccess network client and server";
    inherit (src.meta) homepage;
    license = lib.licenses.bsd3;
    maintainers = with epnixLib.maintainers; [ synthetica ];
  };
}
