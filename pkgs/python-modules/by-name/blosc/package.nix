{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  cmake,
  ninja,
  py-cpuinfo,
  scikit-build,
  setuptools,
  numpy,
  c-blosc,
  unittestCheckHook,
  epnixLib,
}:

buildPythonPackage rec {
  pname = "blosc";
  version = "1.11.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Blosc";
    repo = "python-blosc";
    rev = "v${version}";
    hash = "sha256-EBviPf9D1NFEMwIMzd2zf3jZIQpQCaSE9cvFYdBC7tQ=";
  };

  build-system = [
    py-cpuinfo
    scikit-build
    setuptools
  ];
  dependencies = [ numpy ];

  nativeBuildInputs = [
    cmake
    ninja
  ];
  buildInputs = [ c-blosc ];

  nativeCheckInputs = [ unittestCheckHook ];

  dontUseCmakeConfigure = true;

  # Tests are defined across the whole codebase
  unittestFlags = [
    "-p"
    "*.py"
  ];

  env.USE_SYSTEM_BLOSC = 1;

  pythonImportsCheck = [ "blosc" ];

  meta = {
    description = "A Python wrapper for the extremely fast Blosc compression library";
    homepage = "https://github.com/Blosc/python-blosc";
    license = lib.licenses.bsd3;
    maintainers = with epnixLib.maintainers; [ minijackson ];
  };
}
