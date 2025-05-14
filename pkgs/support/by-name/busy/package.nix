{
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
  epnix,
  local_config_site ? {},
  local_release ? {},
}:
mkEpicsPackage rec {
  pname = "busy";
  version = "1-7-4";
  varname = "BUSY";

  inherit local_config_site local_release;

  src = fetchFromGitHub {
    owner = "epics-modules";
    repo = "busy";
    rev = "R${version}";
    sha256 = "sha256-mSzFLj42iXkyWGWaxplfLehoQcULLpf745trYMd1XT4=";
  };

  patches = [./fix-release.patch];

  buildInputs = with epnix.support; [calc asyn autosave];

  meta = {
    description = "APS BCDA synApps module: busy";
    homepage = "https://epics.anl.gov/bcda/synApps/busy/busy.html";
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [agaget];
  };
}
