{
  lib,
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
  epnix,
}:
mkEpicsPackage rec {
  pname = "modbus";
  version = "3-2";
  varname = "MODBUS";

  src = fetchFromGitHub {
    owner = "epics-modules";
    repo = pname;
    rev = "R3-2";
    hash = "sha256-k8MSgNxib4JT0JTbs0BOm75HIVvxHuVPPlo7VcMCnzg=";
  };

  propagatedBuildInputs = with epnix.support; [asyn];

  meta = {
    description = "EPICS support for communication with PLCs and other devices via the Modbus protocol";
    homepage = "https://epics-modbus.readthedocs.io/en/latest/";
    license = lib.licenses.mit;
    maintainers = with epnixLib.maintainers; [minijackson];
  };
}
