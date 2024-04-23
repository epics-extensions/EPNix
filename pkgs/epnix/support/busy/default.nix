{
  mkEpicsPackage,
  fetchFromGitHub,
  epnix,
  lib,
  epnixLib,
}:
mkEpicsPackage rec {
  pname = "busy";
  version = "1-7-4";

  varname = "BUSY";

  src = fetchFromGitHub {
    owner = "epics-modules";
    repo = pname;
    rev = "R${version}";
    hash = "sha256-mSzFLj42iXkyWGWaxplfLehoQcULLpf745trYMd1XT4=";
  };

  preBuild = ''
    # Busy really wants to define its own location... naughty!
    echo "undefine BUSY" >> configure/RELEASE.local
  '';

  propagatedBuildInputs = with epnix.support; [asyn autosave];

  meta = {
    description = ''
      Gives EPICS application developers a way to signal the completion of an operation
      via EPICS' putNotify mechanism"
    '';

    homepage = "https://github.com/epics-modules/busy";
    # No license specified, https://github.com/epics-modules/busy/issues/15
    license = lib.licenses.unfree;
    maintainers = with epnixLib.maintainers; [synthetica];
  };
}
