{
  lib,
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
  epnix,
  pkg-config,
  rpcsvc-proto,
  libtirpc,
  local_config_site ? {},
  local_release ? {},
}: let
  version = "4-42";
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

    nativeBuildInputs = [pkg-config rpcsvc-proto];
    buildInputs = [libtirpc] ++ (with epnix.support; [ipac seq]);

    patches = [./use-pkg-config.patch];

    src = fetchFromGitHub {
      owner = "epics-modules";
      repo = "asyn";
      rev = "R${version}";
      sha256 = "sha256-Q8s4gaI0YGWGS3xlNVNN+us3xcbEz9/+zdoiFIykZ2s=";
    };

    meta = {
      description = "EPICS module for driver and device support";
      homepage = "https://epics-modules.github.io/master/asyn/";
      license = epnixLib.licenses.epics;
      maintainers = with epnixLib.maintainers; [minijackson];
    };
  }
