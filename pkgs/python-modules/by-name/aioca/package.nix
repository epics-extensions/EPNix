{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  setuptools-scm,
  numpy,
  epicscorelibs,
  epnixLib,
}:
buildPythonPackage rec {
  pname = "aioca";
  version = "2.0";

  pyproject = true;

  src = fetchFromGitHub {
    owner = "DiamondLightSource";
    repo = "aioca";
    tag = version;
    hash = "sha256-aXK+K8y9L9KeYWKs6Fs6AmpX1mDfYJGd8A/Gb11Yswo=";
  };

  build-system = [
    setuptools
    setuptools-scm
  ];
  dependencies = [
    setuptools
    numpy
    epicscorelibs
  ];

  meta = {
    description = "Asynchronous Channel Access client for asyncio and Python using libca via ctypes";
    homepage = "https://DiamondLightSource.github.io/aioca";
    license = lib.licenses.asl20;
    maintainers = with epnixLib.maintainers; [ synthetica ];
  };
}
