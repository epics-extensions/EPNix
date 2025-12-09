{
  epnixLib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  setuptools-dso,
  pip,
  numpy,
}:
buildPythonPackage rec {
  pname = "epicscorelibs";
  version = "7.0.7.99.1.2";

  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-KnSlO0OLu77vE8dGQKTTBg013njOiYnzFYFI84U0zUM=";
  };

  dontConfigure = true;

  build-system = [ setuptools ];
  dependencies = [
    setuptools-dso
    pip
    numpy
  ];

  meta = {
    description = "EPICS core libraries packaged as a Python module";
    homepage = "https://github.com/epics-base/epicscorelibs";
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [ synthetica ];
  };
}
