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
  pname = "ads";
  version = "2023.08.20";
  varname = "ADS";

  inherit local_config_site local_release;

  src = fetchFromGitLab {
    domain = "gitlab.esss.lu.se";
    owner = "epics-modules";
    repo = "epics-twincat-ads";
    rev = "f07f73cd20320e40e908ed281527a81a4799bbce";
    fetchSubmodules = true;
    sha256 = "sha256-NCuT2EpEBEVMzQw4cU8l0AUYVXa9fUtEOGpynG5Z85M=";
  };

  # Patch used to fix parallelization compilation issue caused by EPNix compare to standard compilation.
  # Wait for PR https://gitlab.esss.lu.se/epics-modules/epics-twincat-ads/-/merge_requests/3
  patches = [./fixDep.patch];

  propagatedBuildInputs = with epnix.support; [asyn calc];

  preBuild = ''
    touch configure/RELEASE_PATHS.local
    touch configure/RELEASE_LIBS.local
  '';

  meta = {
    description = "Module providing EPICS support for ADS Protocol (Automation Device Specification)";
    homepage = "https://www.beckhoff.com/en-en/products/automation/twincat/tc1xxx-twincat-3-base/tc1000.html";
    # Wait for ESS team answer about the license :  https://gitlab.esss.lu.se/epics-modules/epics-twincat-ads/-/issues/1
    # lib.licenses.free don't work in EPNIX for now
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [agaget];
  };
}
