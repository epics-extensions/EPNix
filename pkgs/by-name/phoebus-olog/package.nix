{
  lib,
  epnixLib,
  fetchFromGitHub,
  jdk25_headless,
  maven,
  makeWrapper,
}:
maven.buildMavenPackage rec {
  pname = "phoebus-olog";
  version = "6.0.3";

  src = fetchFromGitHub {
    owner = "Olog";
    repo = "phoebus-olog";
    tag = "v${version}";
    hash = "sha256-k5bkHKe5g8EFq9L1KMPrBZL9i27CPdW0U4nWHT5YhQ8=";
  };

  buildOffline = true;
  mvnJdk = jdk25_headless;
  mvnHash = "sha256-PsBGGoQRkKPdpUi6tF2/4Hh3D/R3zNd4IvCHJKTXRbg=";
  mvnParameters = "-Dmaven.javadoc.skip=true -Dmaven.source.skip=true -Pdeployable-jar";

  # Dynamic test dependencies
  # which aren't picked up by go-offline-maven-plugin
  manualMvnArtifacts = [
    "org.springframework.boot:spring-boot-maven-plugin:4.0.0-RC1"
    "org.apache.maven.surefire:surefire-junit-platform:3.5.4"
    "org.junit.platform:junit-platform-launcher:1.12.2"
    "org.jacoco:org.jacoco.agent:0.8.10:jar:runtime"
  ];

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/share/java

    jarName="service-olog-${version}.jar"

    install -Dm644 target/service-olog-${version}.jar $out/share/java

    makeWrapper ${lib.getExe jdk25_headless} $out/bin/${meta.mainProgram} \
      --add-flags "-jar $out/share/java/$jarName"

    runHook postInstall
  '';

  meta = {
    description = "Online logbook for experimental and industrial logging";
    homepage = "https://olog.readthedocs.io/en/latest/";
    mainProgram = "phoebus-olog";
    license = lib.licenses.epl10;
    maintainers = with epnixLib.maintainers; [ minijackson ];
    inherit (jdk25_headless.meta) platforms;
  };
}
