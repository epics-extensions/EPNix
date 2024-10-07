{
  lib,
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
  pkg-config,
  epnix,
  open62541,
  openssl,
  libxml2,
  local_config_site ? {},
  local_release ? {},
}:
mkEpicsPackage {
  pname = "opcua";
  version = "0.10.0";
  varname = "OPCUA";

  src = fetchFromGitHub {
    owner = "epics-modules";
    repo = "opcua";
    rev = "v0.10.0";
    hash = "sha256-l2+TUqVeDh9yRSBXMV0xGrdqBETvc5lfvMRuoqYy1wg=";
  };

  inherit local_release;
  local_config_site =
    local_config_site
    // {
      OPEN62541 = "${open62541}";
      OPEN62541_DEPLOY_MODE = "PROVIDED";
      OPEN62541_LIB_DIR = "${open62541}/lib";
      OPEN62541_SHRLIB_DIR = "${open62541}/lib";
      #for the moment, we're not able to use the last version of openssl to manage a safety connection with the open62541 librairy
      OPEN62541_USE_CRYPTO = "NO";
      OPEN62541_USE_XMLPARSER = "YES";
    };

  patches = [./dir_xml2.patch];

  depsBuildBuild = [pkg-config];
  nativeBuildInputs = [pkg-config open62541 openssl libxml2];
  buildInputs = [open62541 openssl libxml2];
  propagatedNativeBuildInputs = [pkg-config];
  propagatedBuildInputs = [libxml2] ++ (with epnix.support; [gtest]);

  meta = {
    description = "EPICS support for communication with OPC UA protocol";
    homepage = "https://github.com/epics-modules/opcua";
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [vivien];
  };
}
