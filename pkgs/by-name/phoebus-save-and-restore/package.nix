{
  lib,
  epnixLib,
  stdenv,
  maven,
  makeWrapper,
  phoebus-deps,
  phoebus-setup-hook,
}: let
  buildDate = "2022-02-24T07:56:00Z";
in
  stdenv.mkDerivation {
    pname = "phoebus-save-and-restore";
    inherit (phoebus-deps) version src;

    nativeBuildInputs = [maven makeWrapper phoebus-setup-hook];

    buildPhase = ''
      runHook preBuild

      # Copy deps to a writable directory, due to the usage of "install-jars"
      local deps=$PWD/deps
      cp -r --no-preserve=mode "${phoebus-deps}" $deps

      # TODO: tests fail
      mvn package \
        --projects "./services/save-and-restore" \
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
      inherit (phoebus-setup-hook.meta) platforms;
    };
  }
