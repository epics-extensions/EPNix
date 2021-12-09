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
  version = "2-11-4";
  varname = "SSCAN";

  inherit local_config_site local_release;

  buildInputs = with epnix.support; [ seq ];

  patches = [
    # Include shareLib.h, needed for recent base 7.0 where it is no longer indirectly included
    (fetchpatch {
      url = "https://github.com/epics-modules/sscan/commit/420274ca2e4331e92119bd0524d0bcd7ffdd9f93.patch";
      sha256 = "sha256-HRuxsuaodumoQ6asKDsVhYioZEeHtFvln/Oj3XDLIDA=";
    })
  ];

  src = fetchFromGitHub {
    owner = "epics-modules";
    repo = "sscan";
    rev = "R${version}";
    sha256 = "sha256-Br/bH6hCUxdMlJSyMGv/DrALRs945GmgI6ZbssJQWk0=";
  };

  meta = {
    description = "Contains the sscan record and related software for systematically moving positioners, triggering detectors, and acquiring and storing resulting data";
    homepage = "https://epics.anl.gov/bcda/synApps/sscan/sscan.html";
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [ minijackson ];
  };
}
