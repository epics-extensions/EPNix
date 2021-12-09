{ lib
, epnixLib
, mkEpicsPackage
, fetchzip
, re2c
, local_config_site ? { }
, local_release ? { }
}:

mkEpicsPackage rec {
  pname = "seq";
  version = "2.2.6";
  varname = "SNCSEQ";

  inherit local_config_site local_release;

  nativeBuildInputs = [ re2c ];

  preBuild = ''
    echo 'include $(TOP)/configure/RELEASE.local' >> configure/RELEASE
  '';

  src = fetchzip {
    url = "https://www-csr.bessy.de/control/SoftDist/sequencer/releases/seq-${version}.tar.gz";
    sha256 = "sha256-CNy9Mh2CtTcqsQLI1LbWbHf9xfwHlrvI9N7Ifjpi50E=";
  };

  meta = {
    description = "Provides the State Notation Language (SNL), a domain specific programming language";
    homepage = "https://www-csr.bessy.de/control/SoftDist/sequencer/";
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [ minijackson ];
  };
}
