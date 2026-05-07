{
  epnixLib,
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  python,
  flit-core,
  requests,
  simplejson,
  urllib3,
}:
buildPythonPackage rec {
  pname = "channelfinder";
  version = "3.2.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ChannelFinder";
    repo = "pyCFClient";
    tag = "v${version}";
    hash = "sha256-LTaBLjzhVa2s64CGYjfRSprRjNvwIOnfU7WdslBgMGg=";
  };

  build-system = [ flit-core ];

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
