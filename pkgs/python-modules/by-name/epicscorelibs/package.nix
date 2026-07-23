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
  version = "7.0.10.99.0.1";

  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-6MjZcw+u999V9NMpw1mg5MBE8DpSTdLkWH6QEyhz7f0=";
  };

  # https://github.com/epics-base/epicscorelibs/pull/55
  patches = [ ./use-typed-things.patch ];

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
