{
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
  seq,
}:
mkEpicsPackage (finalAttrs: {
  pname = "sscan";
  version = "2-12";
  varname = "SSCAN";

  src = fetchFromGitHub {
    owner = "epics-modules";
    repo = "sscan";
    tag = "R${finalAttrs.version}";
    sha256 = "sha256-3ayoRUPBv8lNnM80VNRCMN6FHbq4csogbrFkwoPjHrI=";
  };

  patches = [
    # https://github.com/epics-modules/sscan/pull/41
    ./fix-k-r-xdrproc-def.patch
  ];

  buildInputs = [ seq ];

  meta = {
    description = "Contains the sscan record and related software for systematically moving positioners, triggering detectors, and acquiring and storing resulting data";
    homepage = "https://epics-modules.github.io/sscan/";
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [ minijackson ];
  };
})
