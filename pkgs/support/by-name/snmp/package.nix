{
  lib,
  epnixLib,
  mkEpicsPackage,
  fetchzip,
  local_config_site ? { },
  local_release ? { },
  net-snmp,
  openssl,
}:
mkEpicsPackage (finalAttrs: {
  pname = "snmp";
  version = "1.1.0.4";
  varname = "SNMP";

  src = fetchzip {
    url = "https://groups.nscl.msu.edu/controls/files/epics-snmp-${finalAttrs.version}.zip";
    hash = "sha256-POIFlyAUNh99213ez5WPe1SQjEpk43QmDLy0dX8SakM=";
    stripRoot = false;
  };

  buildInputs = [
    net-snmp
    openssl
  ];
  nativeBuildInputs = [
    net-snmp
    openssl
  ];

  inherit local_config_site local_release;

  preBuild = ''
    echo 'include $(TOP)/configure/RELEASE.local' >> configure/RELEASE
  '';

  meta = {
    description = "Module providing EPICS support for SNMP (Simple Network Management Protocol)";
    homepage = "https://groups.frib.msu.edu/controls/files/devSnmp.html";
    license = lib.licenses.mit;
    maintainers = with epnixLib.maintainers; [ stephane ];
  };
})
