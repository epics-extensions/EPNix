{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  wheel,
}:
buildPythonPackage rec {
  pname = "scanf";
  version = "1.5.2";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-V2M0QKAqE4zRS2k9CScK8KA7sBfo1M/SSMeYizG4y4E=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  pythonImportsCheck = ["scanf"];

  meta = with lib; {
    description = "A small scanf implementation";
    homepage = "https://pypi.org/project/scanf/";
    license = licenses.mit;
    maintainers = with maintainers; [minijackson];
  };
}
