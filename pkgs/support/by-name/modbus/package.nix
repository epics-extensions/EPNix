{
  lib,
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
  epnix,
}:
mkEpicsPackage rec {
  pname = "modbus";
  version = "3-4";
  varname = "MODBUS";

  src = fetchFromGitHub {
    owner = "epics-modules";
    repo = pname;
    rev = "R${version}";
    hash = "sha256-0v6eLWdjgYKbFOHWaW1NSfN/gG5XHVRD9jan55dXWW0=";
  };

  propagatedBuildInputs = with epnix.support; [asyn];

  meta = {
    description = "EPICS support for communication with PLCs and other devices via the Modbus protocol";
    homepage = "https://epics-modbus.readthedocs.io/en/latest/";
    license = lib.licenses.mit;
    maintainers = with epnixLib.maintainers; [minijackson];
  };
}
