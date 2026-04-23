{
  lib,
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
  asyn,
  calc,
  local_config_site ? { },
  local_release ? { },
}:
mkEpicsPackage (finalAttrs: {
  pname = "twincat-ads";
  version = "2.1.3";
  varname = "TWINCATADS";

  inherit local_config_site local_release;

  src = fetchFromGitHub {
    owner = "epics-modules";
    repo = "twincat-ads";
    tag = "v${finalAttrs.version}";
    fetchSubmodules = true;
    hash = "sha256-VWqvIl8d0/rKTInZyWQ0YbrRoOvmQutEfIQj3NIpSYo=";
  };

  propagatedBuildInputs = [
    asyn
    calc
  ];

  preBuild = ''
    touch configure/RELEASE_PATHS.local
    touch configure/RELEASE_LIBS.local
  '';

  meta = {
    description = "Module providing EPICS support for ADS Protocol (Automation Device Specification)";
    inherit (finalAttrs.src.meta) homepage;
    license = lib.licenses.lgpl3Plus;
    maintainers = with epnixLib.maintainers; [
      agaget
      minijackson
    ];
  };
})
