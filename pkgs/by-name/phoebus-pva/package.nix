{
  lib,
  epnixLib,
  stdenv,
  maven,
  makeWrapper,
  phoebus-deps,
  phoebus-setup-hook,
}:
let
  buildDate = "2022-02-24T07:56:00Z";
in
stdenv.mkDerivation {
  pname = "phoebus-pva";
  inherit (phoebus-deps) version src;

  nativeBuildInputs = [
    maven
    makeWrapper
    phoebus-setup-hook
  ];

  buildPhase = ''
    runHook preBuild

    # Copy deps to a writable directory, due to the usage of "install-jars"
    local deps=$PWD/deps
    cp -r --no-preserve=mode "${phoebus-deps}" $deps

    # TODO: tests fail
    mvn package \
      --projects "./core/pva" \
      --also-make \
      --offline \
      -Dmaven.javadoc.skip=true -Dmaven.source.skip=true -Dmaven.test.skip \
      -Dproject.build.outputTimestamp=${buildDate} \
      -Dmaven.repo.local="$deps"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    installPhoebusJar \
      "core/pva" \
      "core-pva-$version.jar" \
      "phoebus-pva" \
      "org.epics.pva.client.PVAClientMain"

    runHook postInstall
  '';

  meta = {
    description = "Phoebus' PV Access client and server";
    homepage = "https://github.com/ControlSystemStudio/phoebus/tree/master/core/pva";
    mainProgram = "phoebus-pva";
    license = lib.licenses.epl10;
    maintainers = with epnixLib.maintainers; [ minijackson ];
    inherit (phoebus-setup-hook.meta) platforms;
  };
}
