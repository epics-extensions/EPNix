{
  lib,
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
  pkg-config,
  open62541_1_3,
  openssl,
  libxml2,
  gtest,
  local_config_site ? { },
  local_release ? { },
}:
mkEpicsPackage {
  pname = "opcua";
  version = "0.11.2";
  varname = "OPCUA";

  src = fetchFromGitHub {
    owner = "epics-modules";
    repo = "opcua";
    rev = "v0.11.2";
    hash = "sha256-64DBRiGZRGCBeg/cpNK3LRMQ3ciAtGQiUYLNhBJWC+w=";
  };

  inherit local_release;
  local_config_site = local_config_site // {
    OPEN62541 = "${open62541_1_3}";
    OPEN62541_DEPLOY_MODE = "PROVIDED";
    OPEN62541_LIB_DIR = "${open62541_1_3}/lib";
    OPEN62541_SHRLIB_DIR = "${open62541_1_3}/lib";
    #for the moment, we're not able to use the last version of openssl to manage a safety connection with the open62541 librairy
    OPEN62541_USE_CRYPTO = "NO";
    OPEN62541_USE_XMLPARSER = "YES";
  };

  patches = [ ./dir_xml2.patch ];

  depsBuildBuild = [ pkg-config ];
  nativeBuildInputs = [
    pkg-config
    open62541_1_3
    openssl
    libxml2
  ];
  buildInputs = [
    open62541_1_3
    openssl
    libxml2
  ];
  propagatedNativeBuildInputs = [ pkg-config ];
  propagatedBuildInputs = [
    libxml2
    gtest
  ];

  meta = {
    description = "EPICS support for communication with OPC UA protocol";
    homepage = "https://github.com/epics-modules/opcua";
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [ minijackson ];
  };
}
