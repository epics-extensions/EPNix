{
  epnixLib,
  buildPythonPackage,
  pythonAtLeast,
  fetchFromGitHub,
  python,
  setuptools-scm,
  channelfinder,
  requests,
  twisted,
}:
buildPythonPackage rec {
  pname = "RecCeiver";
  version = "1.6";
  pyproject = true;

  # Should be fixed by https://github.com/ChannelFinder/recsync/pull/88
  # but the patch doesn't apply cleanly
  disabled = pythonAtLeast "3.12";

  src = fetchFromGitHub {
    owner = "ChannelFinder";
    repo = "recsync";
    rev = "refs/tags/${version}";
    hash = "sha256-9ApS4e1+oDgZfx7njOuGhezr4ekP2ekJVCc7yiTXRKo=";
  };

  sourceRoot = "${src.name}/server";

  patches = [
    # Defer Python imports of twisted's reactor, to prevent initializing it,
    # preventing the error "reactor already installed"
    # TODO: remove when upgrading to the next release
    ./fix-reactor-import.patch
  ];

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
