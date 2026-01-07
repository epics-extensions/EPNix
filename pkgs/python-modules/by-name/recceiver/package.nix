{
  epnixLib,
  buildPythonPackage,
  fetchFromGitHub,
  python,
  setuptools-scm,
  channelfinder,
  requests,
  twisted,
}:
buildPythonPackage rec {
  pname = "RecCeiver";
  version = "1.7";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ChannelFinder";
    repo = "recsync";
    tag = version;
    hash = "sha256-IXwMEfHxzurqlfY73cAyk1PkLRQMZPhjzX+TIhZxrNU=";
  };

  sourceRoot = "${src.name}/server";

  build-system = [ setuptools-scm ];

  dependencies = [
    channelfinder
    requests
    twisted
  ];

  pythonImportsCheck = [
    "recceiver"
    "recceiver.cfstore"
  ];

  meta = {
    description = "Collects reccaster reports on the state of IOCs within the corresponding subnet and updates ChannelFinder";
    homepage = "https://channelfinder.readthedocs.io/en/latest/";
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [ minijackson ];
    inherit (python.meta) platforms;
  };
}
