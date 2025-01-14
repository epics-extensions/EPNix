{
  buildPythonPackage,
  fetchFromGitHub,
  lib,
  epnixLib,
}:
buildPythonPackage rec {
  pname = "epicsdbbuilder";
  version = "1.5";

  src = fetchFromGitHub {
    owner = "DiamondLightSource";
    repo = pname;
    rev = version;
    hash = "sha256-H+8dJY6nY/4ogxcoZVmZzI7STI4x0urQKddlTifAqGQ=";
  };

  meta = {
    description = "Tool for building EPICS databases";
    homepage = "https://DiamondLightSource.github.io/epicsdbbuilder";
    license = lib.licenses.asl20;
    maintainers = with epnixLib.maintainers; [synthetica];
  };
}
