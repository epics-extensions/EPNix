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
  version = "4-44";
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
    buildInputs = [libtirpc] ++ (with epnix.support; [ipac seq]);

    patches = [./use-pkg-config.patch];

    src = fetchFromGitHub {
      owner = "epics-modules";
      repo = "asyn";
      rev = "R${version}";
      hash = "sha256-V+8ZeG0GpuaCRjC/xcBQYBX72Krz4w1cSgLV/4/kzSk=";
    };

    meta = {
      description = "EPICS module for driver and device support";
      homepage = "https://epics-modules.github.io/master/asyn/";
      license = epnixLib.licenses.epics;
      maintainers = with epnixLib.maintainers; [minijackson];
    };
  }
