{
  lib,
  epnixLib,
  fetchFromGitHub,
  jdk25_headless,
  maven,
  makeWrapper,
}:
maven.buildMavenPackage rec {
  pname = "ChannelFinderService";
  version = "5.1.0";

  src = fetchFromGitHub {
    owner = "ChannelFinder";
    repo = "ChannelFinderService";
    tag = "ChannelFinder-${version}";
    hash = "sha256-O5BUxj4TQan5vEaMxB/OYc0Cr88lPtqAtSBfsnc/RvA=";
  };

  patches = [
    ./support-github-archive.patch
    ./fix-maven-plugin-versions.patch
  ];

  buildOffline = true;
  mvnJdk = jdk25_headless;
  mvnHash = "sha256-zd03/FAGS8LtdEDjgD7JZjgCaMso/akuUfjlR7wQM7k=";
  # Tests require setting up ElasticSearch and Docker
  mvnParameters = "-Dproject.build.outputTimestamp=1980-01-01T00:00:02Z -DskipTests";

  # Dynamic test dependencies
  # which aren't picked up by go-offline-maven-plugin
  manualMvnArtifacts = [
    "org.apache.maven.surefire:surefire-junit-platform:3.1.2"
    "org.junit.platform:junit-platform-launcher:6.0.3"
  ];

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/share/java

    jarName="ChannelFinder-${version}.jar"

    install -Dm644 "target/$jarName" "$out/share/java"

    makeWrapper ${lib.getExe jdk25_headless} $out/bin/${meta.mainProgram} \
      --add-flags "-jar $out/share/java/$jarName"

    runHook postInstall
  '';

  meta = {
    description = "A RESTful directory services for a list channels";
    homepage = "https://channelfinder.readthedocs.io/en/latest/";
    mainProgram = "channel-finder-service";
    license = lib.licenses.mit;
    maintainers = with epnixLib.maintainers; [ minijackson ];
    inherit (jdk25_headless.meta) platforms;
  };
}
