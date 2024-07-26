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
    pname = "phoebus-save-and-restore";
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
        --projects "./services/save-and-restore" \
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
        "services/save-and-restore" \
        "service-save-and-restore-$version.jar" \
        "phoebus-save-and-restore" \
        "org.springframework.boot.loader.JarLauncher"

      runHook postInstall
    '';

    meta = {
      description = "Implements the MASAR (MAchine Save And Restore) service as a REST API";
      homepage = "https://control-system-studio.readthedocs.io/en/latest/services/save-and-restore/doc/index.html";
      mainProgram = "phoebus-save-and-restore";
      license = lib.licenses.epl10;
      maintainers = with epnixLib.maintainers; [minijackson];
      inherit (jdk.meta) platforms;
    };
  }
