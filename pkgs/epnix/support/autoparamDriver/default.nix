{
  mkEpicsPackage,
  fetchFromGitHub,
  epnix,
  lib,
  epnixLib,
}:
mkEpicsPackage rec {
  pname = "autoparamDriver";
  version = "2.0.0";

  varname = "AUTOPARAM";

  src = fetchFromGitHub {
    owner = "Cosylab";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-J2fy/pMwrbwVFULfANuJBl6iE3wju5bQkhkxxk8zRYs=";
  };

  propagatedBuildInputs = with epnix.support; [asyn];

  meta = {
    description = "An asyn driver that creates parameters dynamically based on content of record links";
    homepage = "https://epics.cosylab.com/documentation/autoparamDriver/";
    license = lib.licenses.mit;
    maintainers = with epnixLib.maintainers; [synthetica];
  };
}
