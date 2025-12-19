{
  stdenv,
  epnix,
  epnixLib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  setuptools-scm,
  pyparsing,
  numpy,
  importlib-resources,
}:
buildPythonPackage rec {
  pname = "pyepics";
  version = "3.5.9";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "pyepics";
    repo = pname;
    tag = version;
    hash = "sha256-X09gxahL0Y/leGNgeG+T7BYCIBxgXULjsC5mM8uFgbs=";
  };

  build-system = [
    setuptools
    setuptools-scm
  ];

  buildInputs = [ epnix.epics-base ];

  dependencies = [
    pyparsing
    numpy
    importlib-resources
  ];

  postInstall =
    let
      # TODO: this only works for x86_64-linux
      inherit (stdenv) hostPlatform;
      kernel = hostPlatform.parsed.kernel.name;
      arch = if hostPlatform.isx86 then "" else hostPlatform.parsed.cpu.family;
      bits = toString hostPlatform.parsed.cpu.bits;
      system = "${kernel}${arch}${bits}";

      epicsSystem = epnixLib.toEpicsArch hostPlatform;
    in
    ''
      clibsDir=($out/lib/python*/site-packages/epics/clibs)
      rm -rf $clibsDir/*/
      mkdir $clibsDir/${system}
      # No need to copy libCom, since libca depend on it
      ln -st $clibsDir/${system} ${epnix.epics-base}/lib/${epicsSystem}/libca.so
    '';

  pythonImportsCheck = [ "epics" ];

  meta = {
    description = "Python interface to Epics Channel Access";
    homepage = "https://github.com/pyepics/pyepics";
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [ minijackson ];
  };
}
