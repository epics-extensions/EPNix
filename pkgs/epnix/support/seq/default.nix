{
  lib,
  epnixLib,
  mkEpicsPackage,
  fetchzip,
  re2c,
  local_config_site ? {},
  local_release ? {},
}:
mkEpicsPackage rec {
  pname = "seq";
  version = "2.2.9";
  varname = "SNCSEQ";

  inherit local_config_site local_release;

  nativeBuildInputs = [re2c];

  patches = [
    ./remove-date.patch
    # See: https://epics.anl.gov/epics/tech-talk/2022/msg01183.php
    ./remove_rules_compat.patch
  ];

  preBuild = ''
    echo 'include $(TOP)/configure/RELEASE.local' >> configure/RELEASE
  '';

  src = fetchzip {
    url = "https://www-csr.bessy.de/control/SoftDist/sequencer/releases/seq-${version}.tar.gz";
    sha256 = "sha256-LAqR5Mrph6CNrhpyt/uP5qbaWN0y7sJk6mfxnCk2Jx0=";
  };

  # TODO: Some tests fail
  doCheck = false;

  meta = {
    description = "Provides the State Notation Language (SNL), a domain specific programming language";
    homepage = "https://www-csr.bessy.de/control/SoftDist/sequencer/";
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [minijackson];
  };
}
