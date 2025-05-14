{
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
  pkg-config,
  rpcsvc-proto,
  libtirpc,
  ipac,
  seq,
  local_config_site ? {},
  local_release ? {},
}: let
  version = "4-45";
in
  mkEpicsPackage {
    pname = "asyn";
    inherit version;
    varname = "ASYN";

    inherit local_config_site;
    local_release =
      local_release
      // {
        TIRPC = "YES";
      };

    depsBuildBuild = [pkg-config];
    nativeBuildInputs = [pkg-config rpcsvc-proto libtirpc];
    buildInputs = [libtirpc ipac seq];

    patches = [./use-pkg-config.patch];

    src = fetchFromGitHub {
      owner = "epics-modules";
      repo = "asyn";
      rev = "R${version}";
      hash = "sha256-VOHgDuRSj3dUmCWX+nyCf/i+VNGpC0ZsyIP0qBUG0vw=";
    };

    meta = {
      description = "EPICS module for driver and device support";
      homepage = "https://epics-modules.github.io/master/asyn/";
      license = epnixLib.licenses.epics;
      maintainers = with epnixLib.maintainers; [minijackson];
    };
  }
