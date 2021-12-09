{ lib
, epnixLib
, mkEpicsPackage
, fetchFromGitHub
, fetchpatch
, epnix
, local_config_site ? { }
, local_release ? { }
}:

mkEpicsPackage rec {
  pname = "sscan";
  version = "2-11-5";
  varname = "SSCAN";

  inherit local_config_site local_release;

  buildInputs = with epnix.support; [ seq ];

  src = fetchFromGitHub {
    owner = "epics-modules";
    repo = "sscan";
    rev = "R${version}";
    sha256 = "sha256-WVjQS4b4VBJezKqXqSFaiNLGjKUgoPqHPyNBvKKN77U=";
  };

  meta = {
    description = "Contains the sscan record and related software for systematically moving positioners, triggering detectors, and acquiring and storing resulting data";
    homepage = "https://epics.anl.gov/bcda/synApps/sscan/sscan.html";
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [ minijackson ];
  };
}
