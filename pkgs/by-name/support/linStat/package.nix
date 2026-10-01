{
  lib,
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
}:
mkEpicsPackage {
  pname = "linStat";
  version = "1.2.1";
  varname = "LINSTAT";

  src = fetchFromGitHub {
    owner = "mdavidsaver";
    repo = "linStat";
    tag = "1.2.1";
    hash = "sha256-PbUorNvFC4gNmArliD4xn6jAfes1OM34DaA/wyQlF1U=";
  };

  patches = [ ./dynamic_install_location.patch ];

  meta = {
    description = "An EPICS Driver to serve up Linux system and/or process specific information from an IOC.";
    homepage = "https://github.com/mdavidsaver/linStat";
    license = lib.licenses.lgpl3Only;
    maintainers = with epnixLib.maintainers; [ minijackson ];
  };
}
