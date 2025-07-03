{
  epnixLib,
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  python,
  setuptools,
  requests,
  simplejson,
  urllib3,
}:
buildPythonPackage rec {
  pname = "channelfinder";
  version = "3.0.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ChannelFinder";
    repo = "pyCFClient";
    rev = "refs/tags/v${version}";
    hash = "sha256-83V6OgKUgkui1elroKdVr/KBNriSb9nfo8Ggd68AO/Y=";
  };

  # TODO: when a new version is released, switch to flit-core
  build-system = [ setuptools ];

  dependencies = [
    requests
    simplejson
    urllib3
  ];

  # Tests not run as they need a running ChannelFinder instance

  pythonImportsCheck = [ "channelfinder" ];

  meta = {
    description = "Python ChannelFinder Client Lib";
    homepage = "https://github.com/ChannelFinder/pyCFClient";
    license = lib.licenses.mit;
    maintainers = with epnixLib.maintainers; [ minijackson ];
    inherit (python.meta) platforms;
  };
}
