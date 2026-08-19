{
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
  pkg-config,
  rpcsvc-proto,
  libtirpc,
  ipac,
  seq,
}:
mkEpicsPackage (finalAttrs: {
  pname = "asyn";
  version = "4-46";
  varname = "ASYN";

  src = fetchFromGitHub {
    owner = "epics-modules";
    repo = "asyn";
    tag = "R${finalAttrs.version}";
    hash = "sha256-YdaVKfYo4JljXBrxHN39OFKCaZZtbOgHoLWWgrPhkZE=";
  };

  patches = [
    ./use-pkg-config.patch
  ];

  local_config_site = {
    TIRPC = "YES";
  };

  depsBuildBuild = [ pkg-config ];
  nativeBuildInputs = [
    pkg-config
    rpcsvc-proto
    libtirpc
  ];
  buildInputs = [
    libtirpc
  ];

  propagatedBuildInputs = [
    ipac
    seq
  ];

  meta = {
    description = "EPICS module for driver and device support";
    homepage = "https://epics-modules.github.io/asyn/";
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [ minijackson ];
  };
})
