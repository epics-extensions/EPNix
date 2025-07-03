{
  buildPythonPackage,
  fetchFromGitHub,
  setuptools_dso,
  numpy,
  epicscorelibs,
  pvxslibs,
  cython,
  setuptools,
  lib,
  epnixLib,
}:
buildPythonPackage rec {
  pname = "p4p";
  version = "4.2.0";

  src = fetchFromGitHub {
    owner = "epics-base";
    repo = pname;
    rev = "4.2.0";
    hash = "sha256-3vC3r1xiyi3j8fcXWV+rL4VFvxf6z4//Z7HV3cGkUP4=";
  };

  # Configure exists as a directory, which nix assumes it has to execute...
  dontConfigure = true;

  nativeBuildInputs = [
    setuptools_dso
    cython
  ];
  dependencies = [
    numpy
    epicscorelibs
    pvxslibs
    setuptools
  ];

  meta = {
    description = "Python bindings for the PVAccess network client and server";
    inherit (src) homepage;
    license = lib.licenses.bsd3;
    maintainers = with epnixLib.maintainers; [ synthetica ];
  };
}
