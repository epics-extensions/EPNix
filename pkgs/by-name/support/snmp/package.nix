{
  lib,
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
  net-snmp,
  openssl,
}:
mkEpicsPackage (finalAttrs: {
  pname = "snmp";
  version = "1.1.0.7";
  varname = "SNMP";

  # XXX: we use our own mirror, while waiting for upstream to release it to GitHub.
  # The current official site has a bot protection which prevents us
  # from downloading the release using curl.
  src = fetchFromGitHub {
    owner = "minijackson";
    repo = "epics-snmp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-guQNYMfAcRWwZ26Qqwml7GdB+hXzOsFL5jhHvJ1NIa4=";
  };

  buildInputs = [
    net-snmp
    openssl
  ];
  nativeBuildInputs = [
    net-snmp
    openssl
  ];

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
