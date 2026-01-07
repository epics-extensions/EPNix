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
  version = "3.0.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ChannelFinder";
    repo = "pyCFClient";
    tag = "v${version}";
    hash = "sha256-VCmuezlKUDSEMSmp8Iww45WNY3pGgJG0geRIkubZemw=";
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
