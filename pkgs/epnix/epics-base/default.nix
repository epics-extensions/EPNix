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

  makeFlags = [
    "COMMANDLINE_LIBRARY=READLINE_NCURSES"
    "READLINE_DIR=${readline}"
  ];

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

  propagatedBuildInputs = [ readline ];
  propagatedNativeBuildInputs = [ readline ];

  # TODO: Some tests fail
  doCheck = false;

  postInstall = ''
    pushd "$out/bin"
    while IFS= read -r -d $'\0' i; do
        # Don't symlink perl executables, are the EPICS perl lib is "hardcoded"
        # to be "../../lib/perl"
        if ! isELF "$i"; then continue; fi
        ln -sfn "$i" "$out/bin/"
    done < <(find . -type f -executable -print0)
    popd
  '';

  # TODO: find a way to "symlink" everything what is in ./bin/linux-x86_64 -> ./bin
  meta = {
    description = "The Experimental Physics and Industrial Control System";
    homepage = "https://epics-controls.org/";
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [ minijackson ];
  };
}
