{epnixLib, ...}: {
  update-flake-lock-matrix = {
    branch = epnixLib.versions.supported-branches;
  };
}
