{
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
  devlib2,
  local_config_site ? { },
  local_release ? { },
}:
mkEpicsPackage rec {
  pname = "mrfioc2";
  version = "2.7.2";
  varname = "MRFIOC2";

  inherit local_config_site local_release;

  src = fetchFromGitHub {
    owner = "epics-modules";
    repo = "mrfioc2";
    tag = version;
    sha256 = "sha256-AWwpv5JbnFwLMp/wku0lgI7TL0O0hqC+ycP/ypzwGbU=";
  };

  propagatedBuildInputs = [ devlib2 ];

  meta = {
    description = "EPICS driver for Micro Research Finland event timing system devices";
    inherit (src.meta) homepage;
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [ agaget ];
  };
}
