{
  lib,
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
  fetchpatch,
  epnix,
  local_config_site ? {},
  local_release ? {},
}:
mkEpicsPackage rec {
  pname = "opcua";
  version = "0.9.4";
  varname = "OPCUA";

  doCheck = false;

  inherit local_config_site local_release;

  src = fetchFromGitHub {
    owner = "epics-modules";
    repo = "opcua";
    rev = "v0.9.4";
    hash = "sha256-EADUki6g7c1kO5lFAOioRCsWA+bXQhzncc0nWxH6JVQ=";
  };

  propagatedBuildInputs = with epnix.support; [asyn];

  meta = {
    description = "EPICS support for communication with OPC UA protocol";
    homepage = "https://github.com/epics-modules/opcua";
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [vivien];
  };
}