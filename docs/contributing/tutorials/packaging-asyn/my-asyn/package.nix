{
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
  pkg-config,
  rpcsvc-proto,
  libtirpc,
  calc,
  ipac,
  seq,
  sscan,
  local_config_site ? { },
  local_release ? { },
}:
mkEpicsPackage {
  pname = "my-asyn";
  version = "4-45";
  varname = "MY_ASYN";

  src = fetchFromGitHub {
    owner = "epics-modules";
    repo = "asyn";
    tag = "R4-45";
    hash = "sha256-VOHgDuRSj3dUmCWX+nyCf/i+VNGpC0ZsyIP0qBUG0vw=";
  };

  patches = [ ./use-pkg-config.patch ];

  inherit local_release;
  local_config_site = local_config_site // {
    TIRPC = "YES";
  };

  nativeBuildInputs = [
    pkg-config
    rpcsvc-proto
    libtirpc
  ];
  buildInputs = [ libtirpc ];
  propagatedBuildInputs = [
    calc
    ipac
    seq
    sscan
  ];

  meta = {
    description = "Here is a fancy description of my asyn package";
    homepage = "https://epics-modules.github.io/master/asyn/";
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [ ];
  };
}
