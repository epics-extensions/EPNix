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
  version = "1.8.1";

  pyproject = true;

  src = fetchFromGitHub {
    owner = "DiamondLightSource";
    repo = "aioca";
    rev = "${version}";
    hash = "sha256-szM/sVqeWWUj84lq/wsxNCf/aZwoCySeTnuLD+hYLyc=";
  };

  build-system = [setuptools setuptools-scm];
  dependencies = [
    setuptools
    numpy
    epicscorelibs
  ];

  meta = {
    description = "Asynchronous Channel Access client for asyncio and Python using libca via ctypes";
    homepage = "https://DiamondLightSource.github.io/aioca";
    license = lib.licenses.asl20;
    maintainers = with epnixLib.maintainers; [synthetica];
  };
}
