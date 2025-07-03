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
  version = "7.0.7.99.1.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-+d0sAZE88TlZ6ILHwq/M1dVc1QhL1FlyAeoRn2V1IjE=";
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
