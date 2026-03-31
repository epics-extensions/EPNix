{
  lib,
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
  local_config_site ? { },
  local_release ? { },
}:
mkEpicsPackage (finalAttrs: {
  pname = "ipac";
  version = "2.16";
  varname = "IPAC";

  inherit local_config_site local_release;

  src = fetchFromGitHub {
    owner = "epics-modules";
    repo = "ipac";
    tag = finalAttrs.version;
    hash = "sha256-J39oJ6taVpXlDlPB2tMlAZfpXqIyNzK8hhN9ndvDIbE=";
  };

  meta = {
    description = "IPAC Carrier and Communication Module Drivers";
    homepage = "https://github.com/epics-modules/ipac/wiki";
    license = lib.licenses.lgpl21Plus;
    maintainers = with epnixLib.maintainers; [ minijackson ];
  };
})
