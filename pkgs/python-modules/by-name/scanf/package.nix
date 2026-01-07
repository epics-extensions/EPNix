{
  lib,
  epnixLib,
  buildPythonPackage,
  fetchFromGitHub,
  flit-core,
}:
buildPythonPackage rec {
  pname = "scanf";
  version = "1.6.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "joshburnett";
    repo = pname;
    tag = "v${version}";
    hash = "sha256-xiQh26bkGha8WCSWWdtcL+Ln+J1Rn5NyNKRbdSI1DgI=";
  };

  build-system = [ flit-core ];

  pythonImportsCheck = [ "scanf" ];

  meta = {
    description = "A small scanf implementation";
    inherit (src.meta) homepage;
    license = lib.licenses.mit;
    maintainers = with epnixLib.maintainers; [ minijackson ];
  };
}
