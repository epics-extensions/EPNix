{
  lib,
  epnixLib,
  fetchFromGitHub,
  jre,
  maven,
  makeWrapper,
}:
maven.buildMavenPackage rec {
  pname = "phoebus-olog";
  version = "4.7.7";

  src = fetchFromGitHub {
    owner = "Olog";
    repo = "phoebus-olog";
    rev = "v${version}";
    hash = "sha256-AHZowe4mmBpiFd5MMVRrnUHeTOJDwE6f0sZFUF+07lo=";
  };

  mvnHash = "sha256-xaoaoL1a9VP7e4HdI2YuOUPOADnMYlPesVbkhgLz3+M=";
  mvnParameters = "-Dmaven.javadoc.skip=true -Dmaven.source.skip=true -Pdeployable-jar -Dproject.build.outputTimestamp=1980-01-01T00:00:02Z";

  nativeBuildInputs = [makeWrapper];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/share/java

    jarName="service-olog-${version}.jar"

    install -Dm644 target/service-olog-${version}.jar $out/share/java

    makeWrapper ${lib.getExe jre} $out/bin/${meta.mainProgram} \
      --add-flags "-jar $out/share/java/$jarName"

    runHook postInstall
  '';

  meta = {
    description = "Online logbook for experimental and industrial logging";
    homepage = "https://olog.readthedocs.io/en/latest/";
    mainProgram = "phoebus-olog";
    license = lib.licenses.epl10;
    maintainers = with epnixLib.maintainers; [minijackson];
    inherit (jre.meta) platforms;
  };
}
