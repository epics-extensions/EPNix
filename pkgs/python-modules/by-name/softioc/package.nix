{
  lib,
  buildPythonPackage,
  fetchgit,
  setuptools,
  epicscorelibs,
  pyyaml,
  pvxslibs,
  epicsdbbuilder,
  epnixLib,
}:
buildPythonPackage rec {
  pname = "softioc";
  version = "4.6.1";

  pyproject = true;

  src = fetchgit {
    url = "https://github.com/DiamondLightSource/pythonSoftIOC.git";
    rev = version;
    fetchSubmodules = true;
    hash = "sha256-wvzV+5fwdqKhlZ2QmhLIuw7JdhXtKlfNWMmBiLJgCPY=";
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
    pyyaml
  ];

  meta = {
    description = "Embed an EPICS IOC in a Python process";
    homepage = "https://diamondlightsource.github.io/pythonSoftIOC/";
    license = lib.licenses.asl20;
    maintainers = with epnixLib.maintainers; [ synthetica ];
  };
}
