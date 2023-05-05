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
    pname = "phoebus-scan-server";
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
        --projects "./services/scan-server" \
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
        "services/scan-server" \
        "service-scan-server-$version.jar" \
        "phoebus-scan-server" \
        "org.csstudio.scan.server.ScanServerInstance"

      runHook postInstall
    '';

    meta = {
      description = "Simple, well tested, and robust set of predefined commands for use by Python users";
      homepage = "https://epics.anl.gov/tech-talk/2022/msg01072.php";
      license = lib.licenses.epl10;
      maintainers = with epnixLib.maintainers; [minijackson];
      inherit (jdk.meta) platforms;
    };
  }
