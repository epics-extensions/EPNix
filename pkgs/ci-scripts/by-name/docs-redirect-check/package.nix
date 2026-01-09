{
  lib,
  writeShellApplication,
  git,
  nix,
  epnixLib,
}:
let
  do-linkcheck = writeShellApplication {
    name = "docs-do-redirect-check";

    runtimeInputs = [
      git
      nix
    ];

    text = ''
      eval "$(nix print-dev-env .#docs)"

      export dontUnpack=true
      export dontInstall=true
      cd docs

      export buildPhase="make rediraffecheckdiff"
      genericBuild
    '';
  };
in
writeShellApplication {
  name = "docs-linkcheck";

  text = ''
    env -i TERM="$TERM" "${lib.getExe do-linkcheck}"
  '';

  meta = {
    description = "Script that checks the links in the documentation";
    maintainers = with epnixLib.maintainers; [ minijackson ];
    license = lib.licenses.asl20;
  };
}
