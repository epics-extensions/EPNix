{
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
  seq,
  local_config_site ? {},
  local_release ? {},
}:
mkEpicsPackage rec {
  pname = "sscan";
  version = "2-11-6";
  varname = "SSCAN";

  src = fetchFromGitHub {
    owner = "epics-modules";
    repo = pname;
    rev = "R${version}";
    sha256 = "sha256-hrPap4FBKMD4ddMrADOeTAmsG+rLFxALibT3qsAHNsk=";
  };

  buildInputs = [seq];

  inherit local_config_site local_release;

  meta = {
    description = "Contains the sscan record and related software for systematically moving positioners, triggering detectors, and acquiring and storing resulting data";
    homepage = "https://epics.anl.gov/bcda/synApps/sscan/sscan.html";
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [minijackson];
  };
}
