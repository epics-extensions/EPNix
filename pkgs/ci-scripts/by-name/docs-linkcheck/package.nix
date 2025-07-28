{
  lib,
  writeShellApplication,
  nix,
  epnixLib,
}:
let
  do-linkcheck = writeShellApplication {
    name = "docs-do-linkcheck";

    runtimeInputs = [ nix ];

    text = ''
      eval "$(nix print-dev-env .#docs)"

      export dontUnpack=true
      export dontInstall=true
      cd docs

      export buildPhase="make linkcheck"
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
    description = "Check the links in the documentation";
    maintainers = with epnixLib.maintainers; [ minijackson ];
    hidden = true;
  };
}
