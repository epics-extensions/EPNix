{ lib
, epnixLib
, mkEpicsPackage
, fetchgit
, fetchpatch
, version
, sha256
, readline
, local_config_site ? { }
, local_release ? { }
}:

with lib;

let
  atLeast = versionAtLeast version;
  older = versionOlder version;
in
mkEpicsPackage {
  pname = "epics-base";
  inherit version;
  varname = "EPICS_BASE";

  inherit local_config_site local_release;

  isEpicsBase = true;

  src = fetchgit {
    url = "https://git.launchpad.net/epics-base";
    rev = "R${version}";
    inherit sha256;
  };

  patches = (optionals (older "7.0.5") [
    # Support "undefine MYVAR" in convertRelease.pl
    # Fixed by commit 79d7ac931502e1c25b247a43b7c4454353ac13a6
    ./handle-make-undefine-variable.patch
  ]);

  propagatedBuildInputs = optional (older "7.0.0") readline;

  # TODO: find a way to "symlink" what is in ./bin/linux-x86_64 -> ./bin
  meta = {
    description = "The Experimental Physics and Industrial Control System";
    homepage = "https://epics-controls.org/";
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [ minijackson ];
  };
}
