{
  lib,
  epnix,
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
  fetchpatch,
  local_config_site ? {},
  local_release ? {},
}:
mkEpicsPackage rec {
  pname = "mrfioc2";
  version = "2.6.0";
  varname = "MRFIOC2";

  inherit local_config_site local_release;

  src = fetchFromGitHub {
    owner = "epics-modules";
    repo = "mrfioc2";
    rev = version;
    sha256 = "sha256-pmuM4HrHlZ63BcZACZOlMAPic1IOQ/kLpi9lo/raP0U=";
  };

  propagatedBuildInputs = with epnix.support; [devlib2];

  postInstall = ''
    if [[ -d iocBoot ]]; then
      cp -rafv iocBoot -t "$out"
    fi
  '';

  meta = {
    description = "EPICS driver for Micro Research Finland event timing system devices";
    homepage = "https://github.com/epics-modules/mrfioc2";
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [agaget];
  };
}
