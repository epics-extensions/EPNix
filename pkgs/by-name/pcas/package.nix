{
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
}:
mkEpicsPackage (finalAttrs: {
  pname = "pcas";
  version = "4.13.3";
  varname = "PCAS";

  src = fetchFromGitHub {
    owner = "epics-modules";
    repo = finalAttrs.pname;
    rev = "v${finalAttrs.version}";
    hash = "sha256-wwU2/4CHI/dExqfFL1AzK7d+cMRGU1oxSlhb/3xY7xs=";
  };

  meta = {
    description = "Portable Channel Access Server";
    homepage = "https://github.com/epics-modules/pcas";
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [ minijackson ];
  };
})
