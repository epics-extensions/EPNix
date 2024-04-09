{
  lib,
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
  fetchpatch,
  fetchzip,
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
  version = "0.9.5-InProgress";
  varname = "OPCUA";

  doCheck = false;

  inherit local_release;
  local_config_site =
    local_config_site
    // {
      OPEN62541 = "${open62541}";
      OPEN62541_DEPLOY_MODE = "PROVIDED";
      OPEN62541_LIB_DIR = "${open62541}/lib";
      OPEN62541_SHRLIB_DIR = "${open62541}/lib";
      OPEN62541_USE_CRYPTO = "NO";
    };

  buildInputs = [pkg-config open62541 openssl libxml2];
  nativeBuildInputs = [pkg-config open62541 openssl libxml2];
  #propagatedBuildInputs = with epnix.support; [asyn];

  enableParallelBuilding = false;

  patches = [./dir_xml2.patch];

  preBuild = ''
       echo 'include $(TOP)/configure/RELEASE.local' >> configure/RELEASE
       echo 'include $(TOP)/configure/CONFIG_SITE.local' >> configure/CONFIG_SITE
  '';

  src = fetchFromGitHub {
    owner = "epics-modules";
    repo = "opcua";
    rev = "3d10053";
    hash = "sha256-EQra8PesO7Rlhj+pBlAfiqh5yjJwRkuh7gbGziY58iI=";
  };


  meta = {
    description = "EPICS support for communication with OPC UA protocol";
    homepage = "https://github.com/epics-modules/opcua";
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [vivien];
  };
}