{
  lib,
  epnixLib,
  buildPythonPackage,
  fetchFromGitHub,
  approvaltests,
  setuptools,
  setuptools-scm,
  json-rpc,
  mock,
  pcaspy,
  pytest,
  pyyaml,
  pyzmq,
  scanf,
  semantic-version,
  callPackage,
}:
buildPythonPackage rec {
  pname = "lewis";
  version = "1.4.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ISISComputingGroup";
    repo = "lewis";
    tag = "v${version}";
    hash = "sha256-P5R+PrAVkoJtre2cwbt2/UgbE1E8KACoxsmEd6RlYtI=";
  };

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    json-rpc
    pcaspy
    pyyaml
    pyzmq
    scanf
    semantic-version
  ];

  checkInputs = [
    approvaltests
    mock
    pytest
  ];

  pythonImportsCheck = [ "lewis" ];

  passthru = callPackage ./lib.nix { };

  meta = {
    description = "Let's write intricate simulators";
    inherit (src.meta) homepage;
    mainProgram = "lewis";
    license = lib.licenses.gpl3Only;
    maintainers = with epnixLib.maintainers; [ minijackson ];
  };
}
