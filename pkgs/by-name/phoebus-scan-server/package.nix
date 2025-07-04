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
  pname = "phoebus-scan-server";
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
      --projects "./services/scan-server" \
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
      "services/scan-server" \
      "service-scan-server-$version.jar" \
      "phoebus-scan-server" \
      "org.csstudio.scan.server.ScanServerInstance"

    runHook postInstall
  '';

  meta = {
    description = "Simple, well tested, and robust set of predefined commands for use by Python users";
    homepage = "https://epics.anl.gov/tech-talk/2022/msg01072.php";
    mainProgram = "phoebus-scan-server";
    license = lib.licenses.epl10;
    maintainers = with epnixLib.maintainers; [ minijackson ];
    inherit (phoebus-setup-hook.meta) platforms;
  };
}
