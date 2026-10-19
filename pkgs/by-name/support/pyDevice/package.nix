{
  lib,
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
  python3,
}:
mkEpicsPackage {
  pname = "pyDevice";
  version = "R1.3.3";
  varname = "PYDEVICE";

  src = fetchFromGitHub {
    owner = "klemenv";
    repo = "PyDevice";
    tag = "R1.3.3";
    hash = "sha256-oEsm3onrKp2duN8dTNaV0MVRvHeMg9P5xSLueUXnMhs=";
  };

  nativeBuildInputs = [ python3 ];

  meta = {
    description = "PyDevice is an EPICS device support for Python interpreter. It allows to connect EPICS database records with Python code.";
    homepage = "https://github.com/klemenv/PyDevice";
    license = lib.licenses.gpl3Only;
    maintainers = with epnixLib.maintainers; [ minijackson ];
  };
}
