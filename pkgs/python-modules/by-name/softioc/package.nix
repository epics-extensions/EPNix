{
  lib,
  buildPythonPackage,
  fetchgit,
  setuptools,
  epicscorelibs,
  pvxslibs,
  epicsdbbuilder,
  epnixLib,
}:
buildPythonPackage rec {
  pname = "softioc";
  version = "4.5.0";

  pyproject = true;

  src = fetchgit {
    url = "https://github.com/DiamondLightSource/pythonSoftIOC.git";
    rev = version;
    fetchSubmodules = true;
    hash = "sha256-JXfFkA3MzipqUw0riMTZmgCP9qe4Tfj8vZaFBwqoO+c=";
  };

  # Set correct version instead of automatically detected version:
  postPatch = ''
    awk -i inplace "/__version__/ && !x {print; print \"__version__ = '${version}'\"; x=1; next} 1" setup.py
  '';

  build-system = [ setuptools ];
  dependencies = [
    setuptools
    epicscorelibs
    epicsdbbuilder
    pvxslibs
  ];

  meta = {
    description = "Embed an EPICS IOC in a Python process";
    homepage = "https://diamondlightsource.github.io/pythonSoftIOC/";
    license = lib.licenses.asl20;
    maintainers = with epnixLib.maintainers; [ synthetica ];
  };
}
