{
  lib,
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
  fetchpatch,
  devlib2,
  local_config_site ? { },
  local_release ? { },
}:
mkEpicsPackage rec {
  pname = "mrfioc2";
  version = "2.7.1";
  varname = "MRFIOC2";

  inherit local_config_site local_release;

  src = fetchFromGitHub {
    owner = "epics-modules";
    repo = "mrfioc2";
    rev = version;
    sha256 = "sha256-zK+cCWK9oOTH+NvCO0GiWKkwmtQYXvUuONSIV55pY1Y=";
  };

  propagatedBuildInputs = [ devlib2 ];

  postInstall = ''
    if [[ -d iocBoot ]]; then
      cp -rafv iocBoot -t "$out"
    fi
  '';

  meta = {
    description = "EPICS driver for Micro Research Finland event timing system devices";
    homepage = "https://github.com/epics-modules/mrfioc2";
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [ agaget ];
  };
}
