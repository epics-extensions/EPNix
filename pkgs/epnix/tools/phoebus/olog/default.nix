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
  version = "4.7.3";

  src = fetchFromGitHub {
    owner = "Olog";
    repo = "phoebus-olog";
    rev = "v${version}";
    hash = "sha256-WwRB4QtZBeH6GptTZJ02CBpP7BGzjZbwMYQrOmGevFo=";
  };

  mvnHash = "sha256-D1n5PfGulIgdjd60mChVLH1kQDOUcc/TvEw3oJUZ1h4=";
  mvnParameters = "-Dmaven.javadoc.skip=true -Dmaven.source.skip=true -Pdeployable-jar -Dproject.build.outputTimestamp=1980-01-01T00:00:02Z";

  nativeBuildInputs = [makeWrapper];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/share/java

    jarName="service-olog-${version}.jar"

    install -Dm644 target/service-olog-4.7.3.jar $out/share/java
    # Strip the script at the beginning of the jar, so that we are able to
    # canonicalize it
    sed -i '1,/^exit 0$/d' $out/share/java/$jarName

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
