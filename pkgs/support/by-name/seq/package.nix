{
  lib,
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
  fetchpatch2,
  re2c,
}:
mkEpicsPackage (finalAttrs: {
  pname = "seq";
  version = "2.2.9";
  varname = "SNCSEQ";

  src = fetchFromGitHub {
    owner = "epics-modules";
    repo = "sequencer";
    tag = "R${lib.replaceString "." "-" finalAttrs.version}";
    sha256 = "sha256-FVwj6puPEGYW23X0JlpgHpAKszdVuHp9bQ7B8lNhGu4=";
  };

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

  nativeBuildInputs = [ re2c ];

  preBuild = ''
    echo 'include $(TOP)/configure/RELEASE.local' >> configure/RELEASE
  '';

  # TODO: Some tests fail
  doCheck = false;

  meta = {
    description = "Provides the State Notation Language (SNL), a domain specific programming language";
    homepage = "https://epics-modules.github.io/sequencer/index.html";
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [ minijackson ];
  };
})
