{
  lib,
  epnixLib,
  epnix,
  mkEpicsPackage,
  fetchFromGitLab,
  local_config_site ? {},
  local_release ? {},
}:
mkEpicsPackage rec {
  pname = "twincat-ads";
  version = "2024.01.11";
  varname = "TWINCATADS";

  inherit local_config_site local_release;

  src = fetchFromGitLab {
    domain = "gitlab.esss.lu.se";
    owner = "epics-modules";
    repo = "epics-twincat-ads";
    rev = "c8e8b52c1f34640eca97b8fb053e793dc68acc0a";
    fetchSubmodules = true;
    sha256 = "sha256-f7hod1N1AzCh+W7nHl9VCA+nuwpJAboSh19Dq80n/2E=";
  };

  # See: https://gitlab.esss.lu.se/epics-modules/epics-twincat-ads/-/issues/2
  patches = [./fix-missing-header.patch];

  propagatedBuildInputs = with epnix.support; [asyn calc];

  preBuild = ''
    touch configure/RELEASE_PATHS.local
    touch configure/RELEASE_LIBS.local
  '';

  meta = {
    description = "Module providing EPICS support for ADS Protocol (Automation Device Specification)";
    homepage = "https://gitlab.esss.lu.se/epics-modules/epics-twincat-ads";
    # Wait for ESS team answer about the license :  https://gitlab.esss.lu.se/epics-modules/epics-twincat-ads/-/issues/1
    license = lib.licenses.free;
    maintainers = with epnixLib.maintainers; [agaget];
  };
}
