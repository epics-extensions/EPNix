{
  buildPythonPackage,
  epnix,
  setuptools,
  setuptools-dso,
  epicscorelibs,
}:
buildPythonPackage {
  pname = "pvxslibs";
  inherit (epnix.support.pvxs) version src;
  pyproject = true;

  dontConfigure = true;

  build-system = [ setuptools ];
  nativeBuildInputs = [
    setuptools-dso
    epicscorelibs
  ];

  inherit (epnix.support.pvxs) meta;
}
