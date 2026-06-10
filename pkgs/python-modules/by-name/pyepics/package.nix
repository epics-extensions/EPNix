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
  sphinxHook,
  sphinx-copybutton,
  numpydoc,
}:
buildPythonPackage (finalAttrs: {
  pname = "pyepics";
  version = "3.5.10";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "pyepics";
    repo = "pyepics";
    tag = finalAttrs.version;
    hash = "sha256-eTM/duEIk8l6VPdrjQvJ+c+SHpg7cLmjnLCAOrFsO/c=";
  };

  build-system = [
    setuptools
    setuptools-scm
  ];

  nativeBuildInputs = [
    sphinxHook
    sphinx-copybutton
    numpydoc
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
})
