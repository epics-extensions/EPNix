{
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
}:
mkEpicsPackage (finalAttrs: {
  pname = "devlib2";
  version = "2.12";
  varname = "DEVLIB2";
  #tests seems to need a PCI device to be validated.
  doCheck = false;

  src = fetchFromGitHub {
    owner = "epics-modules";
    repo = "devlib2";
    rev = finalAttrs.version;
    hash = "sha256-5rjilz+FO6ZM+Hn7AVwyFG2WWBoBUQA4WW5OHhhdXw4=";
  };

  meta = {
    description = "Library for direct MMIO access to PCI and VME64x";
    inherit (finalAttrs.src.meta) homepage;
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [ agaget ];
  };
})
