{
  lib,
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
  local_config_site ? { },
  local_release ? { },
}:
mkEpicsPackage {
  pname = "gtest";
  version = "1.0.1";
  varname = "GTEST";

  src = fetchFromGitHub {
    owner = "epics-modules";
    repo = "gtest";
    rev = "v1.0.1";
    hash = "sha256-cDZ4++AkUiOvsw4KkobyqKWLk2GzUSdDdWjLL7dr1ac=";
  };

  inherit local_release local_config_site;

  meta = {
    description = "EPICS module to adds the Google Test and Google Mock frameworks to EPICS";
    homepage = "https://github.com/epics-modules/gtest";
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [ minijackson ];
  };
}
