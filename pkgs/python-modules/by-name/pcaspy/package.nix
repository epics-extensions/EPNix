{
  stdenv,
  lib,
  epnixLib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  swig,
  epnix,
}:

buildPythonPackage (finalAttrs: {
  pname = "pcaspy";
  version = "0.8.1";
  pyproject = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "paulscherrerinstitute";
    repo = "pcaspy";
    tag = finalAttrs.version;
    hash = "sha256-X+75FAU+NCHwXjQY+d02GFvvdrsprhkBZWkR5+V+YWQ=";
  };

  build-system = [ setuptools ];

  nativeBuildInputs = [ swig ];

  env = {
    EPICS_BASE = "${epnix.epics-base}";
    EPICS_HOST_ARCH = "${epnixLib.toEpicsArch stdenv.buildPlatform}";
    PCAS = "${epnix.pcas}";
  };

  pythonImportsCheck = [
    "pcaspy"
    "pcaspy.cas"
  ];

  meta = {
    description = "Portable Channel Access Server in Python";
    homepage = "https://github.com/paulscherrerinstitute/pcaspy";
    changelog = "https://github.com/paulscherrerinstitute/pcaspy/blob/${finalAttrs.src.rev}/CHANGES";
    license = lib.licenses.bsd3;
    maintainers = with epnixLib.maintainers; [ minijackson ];
  };
})
