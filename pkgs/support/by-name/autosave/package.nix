{
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
  local_config_site ? { },
  local_release ? { },
}:
mkEpicsPackage rec {
  pname = "autosave";
  version = "5-11";
  varname = "AUTOSAVE";

  inherit local_config_site local_release;

  src = fetchFromGitHub {
    owner = "epics-modules";
    repo = "autosave";
    rev = "R${version}";
    sha256 = "sha256-T6b2SUxgh2l+F4Vi3oF1aaLIjghlg34tLlwJOgGceLQ=";
  };

  meta = {
    description = "Module that automatically saves values of EPICS PVs to files, and restores those values when the IOC is restarted.";
    homepage = "https://github.com/epics-modules/autosave";
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [ stephane ];
  };
}
