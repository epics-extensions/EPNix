{
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
  epnix,
  local_config_site ? {},
  local_release ? {},
}:
mkEpicsPackage rec {
  pname = "calc";
  version = "3-7-5";
  varname = "CALC";

  inherit local_config_site local_release;

  buildInputs = with epnix.support; [sscan];

  src = fetchFromGitHub {
    owner = "epics-modules";
    repo = "calc";
    rev = "R${version}";
    sha256 = "sha256-S40HtO7HXDS27u7wmlxuo7oV1abtj1EaXfIz0Kj1IM0=";
  };

  meta = {
    description = "Support for run-time expression evaluation";
    homepage = "https://epics.anl.gov/bcda/synApps/calc/calc.html";
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [minijackson];
  };
}
