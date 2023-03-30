{
  lib,
  epnixLib,
  stdenv,
  maven,
  makeWrapper,
  epnix,
  jdk,
}: let
  buildDate = "2022-02-24T07:56:00Z";
in
  stdenv.mkDerivation {
    pname = "phoebus-alarm-logger";
    inherit (epnix.phoebus-deps) version src;

    # TODO: make a scope, so that we don't pass around the whole `epnix`
    nativeBuildInputs = [maven makeWrapper epnix.phoebus-setup-hook];

    buildPhase = ''
      runHook preBuild

      # Copy deps to a writable directory, due to the usage of "install-jars"
      local deps=$PWD/deps
      cp -r --no-preserve=mode "${epnix.phoebus-deps}" $deps

      # TODO: tests fail
      mvn package \
        --projects "./services/alarm-logger" \
        --also-make \
        --offline \
        -Dmaven.javadoc.skip=true -Dmaven.source.skip=true -DskipTests \
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
      license = lib.licenses.epl10;
      maintainers = with epnixLib.maintainers; [minijackson];
      inherit (jdk.meta) platforms;
    };
  }
