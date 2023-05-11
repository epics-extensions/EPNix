{
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
  local_config_site ? {},
  local_release ? {},
}:
mkEpicsPackage rec {
  pname = "autosave";
  version = "5-10-2";
  varname = "AUTOSAVE";

  inherit local_config_site local_release;

  src = fetchFromGitHub {
    owner = "epics-modules";
    repo = "autosave";
    rev = "R${version}";
    sha256 = "sha256-PUUPkiQS3MSrnjG4PzvZ6XrK9Tmt0OohvpduBqnxyyw=";
  };

  meta = {
    description = "Module that automatically saves values of EPICS PVs to files, and restores those values when the IOC is restarted.";
    homepage = "https://github.com/epics-modules/autosave";
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [stephane];
  };
}
