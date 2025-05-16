{
  lib,
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
  fetchpatch,
  local_config_site ? {},
  local_release ? {},
}:
mkEpicsPackage rec {
  pname = "devlib2";
  version = "2.12";
  varname = "DEVLIB2";
  #tests seems to need a PCI device to be validated.
  doCheck = false;

  inherit local_config_site local_release;

  src = fetchFromGitHub {
    owner = "epics-modules";
    repo = "devlib2";
    rev = version;
    sha256 = "sha256-5rjilz+FO6ZM+Hn7AVwyFG2WWBoBUQA4WW5OHhhdXw4=";
  };

  meta = {
    description = "devLib2 - Library for direct MMIO access to PCI and VME64x";
    homepage = "https://github.com/epics-modules/devlib2";
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [agaget];
  };
}
