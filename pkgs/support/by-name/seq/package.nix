{
  epnixLib,
  mkEpicsPackage,
  fetchdarcs,
  fetchpatch2,
  re2c,
}:
mkEpicsPackage {
  pname = "seq";
  version = "2.2.9";
  varname = "SNCSEQ";

  nativeBuildInputs = [ re2c ];

  patches = [
    ./remove-date.patch
    # See: https://epics.anl.gov/epics/tech-talk/2022/msg01183.php
    ./remove_rules_compat.patch

    (fetchpatch2 {
      name = "lemon-add-missing-arguments-to-prototypes.patch";
      url = "https://github.com/epics-modules/sequencer/commit/de4f7c21fb73a4fe780fa25c78d725ac050409de.patch?full_index=1";
      hash = "sha256-Sqso2NMVLw4GkCDCpp2AA9O444NueGt/bXkLXslcx5k=";
    })
  ];

  preBuild = ''
    echo 'include $(TOP)/configure/RELEASE.local' >> configure/RELEASE
  '';

  src = fetchdarcs {
    url = "https://hub.darcs.net/bf/seq-branch-2-2";
    rev = "R2-2-9";
    sha256 = "sha256-LAqR5Mrph6CNrhpyt/uP5qbaWN0y7sJk6mfxnCk2Jx0=";
  };

  # TODO: Some tests fail
  doCheck = false;

  meta = {
    description = "Provides the State Notation Language (SNL), a domain specific programming language";
    homepage = "https://epics-modules.github.io/sequencer/index.html";
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [ minijackson ];
  };
}
