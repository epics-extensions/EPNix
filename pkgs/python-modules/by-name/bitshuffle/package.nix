{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  cython,
  h5py,
  numpy,
  setuptools,
  pkg-config,
  hdf5,
  epnixLib,
}:

buildPythonPackage rec {
  pname = "bitshuffle";
  version = "0.5.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "kiyo-masui";
    repo = "bitshuffle";
    rev = version;
    hash = "sha256-743Syk4E83hi2L8F9cggOZupK1jyewtV+WoDSpzHn/w=";
  };

  build-system = [
    setuptools
    cython
  ];
  dependencies = [
    h5py
    numpy
  ];

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ hdf5 ];

  pythonImportsCheck = [ "bitshuffle" ];

  meta = {
    description = "Filter for improving compression of typed binary data";
    homepage = "https://github.com/kiyo-masui/bitshuffle";
    license = lib.licenses.mit;
    maintainers = with epnixLib.maintainers; [ minijackson ];
  };
}
