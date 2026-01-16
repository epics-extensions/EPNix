{
  lib,
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
  libevent,
  local_config_site ? { },
  local_release ? { },
}:
mkEpicsPackage (finalAttrs: {
  pname = "pvxs";
  version = "1.5.0";
  varname = "PVXS";

  inherit local_config_site local_release;

  src = fetchFromGitHub {
    owner = "epics-base";
    repo = "pvxs";
    tag = finalAttrs.version;
    hash = "sha256-aG/rm/ycSyViJ94vDnXMnd7WKdKQieYBb0z/QknGXc4=";
    fetchSubmodules = true;
  };

  # TODO: check pvxs cross-compilation,
  # since it has a somewhat complex logic for finding libevent
  propagatedNativeBuildInputs = [ libevent ];
  propagatedBuildInputs = [ libevent ];

  # Only loopback interface is present
  doCheck = false;

  meta = {
    description = "PVA protocol client/server library and utilities";
    homepage = "https://epics-base.github.io/pvxs/";
    changelog = "https://epics-base.github.io/pvxs/releasenotes.html";
    license = lib.licenses.bsd3;
    maintainers = with epnixLib.maintainers; [ minijackson ];
  };
})
