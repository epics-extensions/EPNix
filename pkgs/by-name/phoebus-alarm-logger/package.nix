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
  pname = "phoebus-alarm-logger";
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
      --projects "./services/alarm-logger" \
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
      "services/alarm-logger" \
      "service-alarm-logger-$version.jar" \
      "phoebus-alarm-logger" \
      "org.springframework.boot.loader.JarLauncher"

    runHook postInstall
  '';

  meta = {
    description = "Records all alarm messages to create an archive of all alarm state changes and the associated actions";
    homepage = "https://control-system-studio.readthedocs.io/en/latest/services/alarm-logger/doc/index.html";
    mainProgram = "phoebus-alarm-logger";
    license = lib.licenses.epl10;
    maintainers = with epnixLib.maintainers; [ minijackson ];
    inherit (phoebus-setup-hook.meta) platforms;
  };
}
