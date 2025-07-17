{
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
  pkg-config,
  rpcsvc-proto,
  libtirpc,
  ipac,
  seq,
  local_config_site ? { },
  local_release ? { },
}:
let
  version = "4-45";
in
mkEpicsPackage {
  pname = "asyn";
  inherit version;
  varname = "ASYN";

  src = fetchFromGitHub {
    owner = "epics-modules";
    repo = "asyn";
    tag = "R${version}";
    hash = "sha256-VOHgDuRSj3dUmCWX+nyCf/i+VNGpC0ZsyIP0qBUG0vw=";
  };

  patches = [ ./use-pkg-config.patch ];

  inherit local_release;
  local_config_site = local_config_site // {
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
    homepage = "https://epics-modules.github.io/master/asyn/";
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [ minijackson ];
  };
}
