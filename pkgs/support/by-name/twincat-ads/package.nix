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
mkEpicsPackage {
  pname = "twincat-ads";
  version = "2024.09.04";
  varname = "TWINCATADS";

  inherit local_config_site local_release;

  src = fetchFromGitHub {
    owner = "epics-modules";
    repo = "twincat-ads";
    rev = "be1ea2fbef1713b95f75f545eed202e10a980366";
    fetchSubmodules = true;
    sha256 = "sha256-rp2o0V+Jr4FRIG9mZKcwYDbitwSYhNVHaxm4MWBElQQ=";
  };

  # See: https://gitlab.esss.lu.se/epics-modules/epics-twincat-ads/-/issues/2
  patches = [ ./fix-missing-header.patch ];

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
    homepage = "https://github.com/epics-modules/twincat-ads/";
    license = lib.licenses.lgpl3Plus;
    maintainers = with epnixLib.maintainers; [
      agaget
      minijackson
    ];
  };
}
