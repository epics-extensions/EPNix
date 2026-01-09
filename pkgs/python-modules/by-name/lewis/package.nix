{
  lib,
  epnixLib,
  buildPythonPackage,
  pythonAtLeast,
  fetchFromGitHub,
  approvaltests,
  setuptools,
  setuptools-scm,
  json-rpc,
  mock,
  pyasynchat,
  pytest,
  pyyaml,
  pyzmq,
  scanf,
  semantic-version,
}:
buildPythonPackage rec {
  pname = "lewis";
  version = "1.3.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ISISComputingGroup";
    repo = "lewis";
    tag = "v${version}";
    hash = "sha256-VXZE+j/shlz1mLbDYECDNmLEeFGd2pl6+LEOGVHe0Zs=";
  };

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    json-rpc
    pyyaml
    pyzmq
    scanf
    semantic-version
  ]
  ++ (lib.optional (pythonAtLeast "3.12") pyasynchat);

  checkInputs = [
    approvaltests
    mock
    pytest
  ];

  pythonImportsCheck = [ "lewis" ];

  meta = {
    description = "Let's write intricate simulators";
    inherit (src.meta) homepage;
    mainProgram = "lewis";
    license = lib.licenses.gpl3Only;
    maintainers = with epnixLib.maintainers; [ minijackson ];
  };
}
