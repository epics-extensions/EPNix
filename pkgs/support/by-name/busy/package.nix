{
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
  asyn,
  autosave,
  calc,
  local_config_site ? { },
  local_release ? { },
}:
mkEpicsPackage (finalAttrs: {
  pname = "busy";
  version = "1-7-4";
  varname = "BUSY";

  inherit local_config_site local_release;

  src = fetchFromGitHub {
    owner = "epics-modules";
    repo = "busy";
    tag = "R${finalAttrs.version}";
    hash = "sha256-mSzFLj42iXkyWGWaxplfLehoQcULLpf745trYMd1XT4=";
  };

  patches = [ ./fix-release.patch ];

  buildInputs = [
    calc
    asyn
    autosave
  ];

  meta = {
    description = "APS BCDA synApps module: busy";
    homepage = "https://epics.anl.gov/bcda/synApps/busy/busy.html";
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [ agaget ];
  };
})
