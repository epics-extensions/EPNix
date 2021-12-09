{ lib
, epnixLib
, mkEpicsPackage
, fetchFromGitHub
, epnix
, local_config_site ? { }
, local_release ? { }
}:

mkEpicsPackage rec {
  pname = "calc";
  version = "3-7-4";
  varname = "CALC";

  inherit local_config_site local_release;

  buildInputs = with epnix.support; [ sscan ];

  src = fetchFromGitHub {
    owner = "epics-modules";
    repo = "calc";
    rev = "R${version}";
    sha256 = "sha256-cZA9M60YAzCeBZB7amxQES6W4Bh1KFrm3ko7Js7Oa5I=";
  };

  meta = {
    description = "Support for run-time expression evaluation";
    homepage = "https://epics.anl.gov/bcda/synApps/calc/calc.html";
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [ minijackson ];
  };
}
