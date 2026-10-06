{
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
}:
mkEpicsPackage {
  pname = "iocStats";
  version = "R4-0-1";
  varname = "DEVIOCSTATS";

  src = fetchFromGitHub {
    owner = "epics-modules";
    repo = "iocStats";
    tag = "4.0.1";
    hash = "sha256-tyc8WguzQ7HkdW28MiPVpcxP5YdkTO9R380kK4/c4Tc=";
  };

  patches = [
    # https://github.com/epics-modules/iocStats/pull/90
    ./port_to_gcc15.patch
  ];

  meta = {
    description = "devIocStats provides support for records that show the health and status of an IOC, plus a few IOC control records.";
    homepage = "https://github.com/epics-modules/iocStats";
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [ minijackson ];
  };
}
