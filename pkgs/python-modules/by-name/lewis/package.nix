{
  lib,
  epnixLib,
  buildPythonPackage,
  pythonAtLeast,
  fetchFromGitHub,
  approvaltests,
  setuptools,
  wheel,
  json-rpc,
  mock,
  pytest,
  pyyaml,
  pyzmq,
  scanf,
  semantic-version,
}:
buildPythonPackage rec {
  pname = "lewis";
  version = "1.3.1";
  pyproject = true;

  # Due to mrjob, which is needed by approvaltests
  disabled = pythonAtLeast "3.12";

  src = fetchFromGitHub {
    owner = "ISISComputingGroup";
    repo = "lewis";
    rev = "v${version}";
    hash = "sha256-7iMREHt6W26IzCFsRmojHqGuqIUHaCuvsKMMHuYflz0=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    json-rpc
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

  meta = {
    description = "Let's write intricate simulators";
    homepage = "https://github.com/ISISComputingGroup/lewis";
    mainProgram = "lewis";
    license = lib.licenses.gpl3Only;
    maintainers = with epnixLib.maintainers; [ minijackson ];
  };
}
