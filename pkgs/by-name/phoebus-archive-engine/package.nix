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
    pname = "phoebus-archive-engine";
    inherit (phoebus-deps) version src;

    nativeBuildInputs = [maven makeWrapper phoebus-setup-hook];

    buildPhase = ''
      runHook preBuild

      # Copy deps to a writable directory, due to the usage of "install-jars"
      local deps=$PWD/deps
      cp -r --no-preserve=mode "${phoebus-deps}" $deps

      # TODO: tests fail
      mvn package \
        --projects "./services/archive-engine" \
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
        "services/archive-engine" \
        "service-archive-engine-$version.jar" \
        "phoebus-archive-engine" \
        "org.csstudio.archive.Engine"

      runHook postInstall
    '';

    meta = {
      description = "Phoebus' RDB Archive Engine Service";
      homepage = "https://control-system-studio.readthedocs.io/en/latest/services/archive-engine/doc/index.html";
      mainProgram = "phoebus-archive-engine";
      license = lib.licenses.epl10;
      maintainers = with epnixLib.maintainers; [minijackson];
      inherit (phoebus-setup-hook.meta) platforms;
    };
  }
