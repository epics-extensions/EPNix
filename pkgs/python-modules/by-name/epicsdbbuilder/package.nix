{
  buildPythonPackage,
  fetchFromGitHub,
  lib,
  epnixLib,
  setuptools,
}:
buildPythonPackage rec {
  pname = "epicsdbbuilder";
  version = "1.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "DiamondLightSource";
    repo = pname;
    tag = version;
    hash = "sha256-H+8dJY6nY/4ogxcoZVmZzI7STI4x0urQKddlTifAqGQ=";
  };

  patches = [ ./relax-deps.patch ];

  build-system = [ setuptools ];

  meta = {
    description = "Tool for building EPICS databases";
    homepage = "https://DiamondLightSource.github.io/epicsdbbuilder";
    license = lib.licenses.asl20;
    maintainers = with epnixLib.maintainers; [ synthetica ];
  };
}
