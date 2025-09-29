{
  lib,
  epnixLib,
  fetchFromGitHub,
  jdk21,
  maven,
  makeWrapper,
}:
maven.buildMavenPackage rec {
  pname = "ChannelFinderService";
  version = "4.7.3";

  src = fetchFromGitHub {
    owner = "ChannelFinder";
    repo = pname;
    rev = "refs/tags/ChannelFinder-${version}";
    hash = "sha256-RZbdUFdDt0Q2ZgbgtnhUQIObl6Ug5Lzbphh4aHdUAwQ=";
  };

  patches = [ ./support-github-archive.patch ];

  buildOffline = true;
  mvnJdk = jdk21;
  mvnHash = "sha256-WoB97KFBJuTBIBH7gPfBYiQl3g7jA5OwVj01WstQr34=";
  mvnParameters = "-Dproject.build.outputTimestamp=1980-01-01T00:00:02Z";

  # Dynamic test dependencies
  # which aren't picked up by go-offline-maven-plugin
  manualMvnArtifacts = [
    "org.apache.maven.surefire:surefire-junit-platform:3.1.2"
    "org.junit.platform:junit-platform-launcher:1.8.2"
    "org.jacoco:org.jacoco.agent:0.8.11:jar:runtime"
  ];

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/share/java

    jarName="ChannelFinder-${version}.jar"

    install -Dm644 "target/$jarName" "$out/share/java"

    makeWrapper ${lib.getExe jdk21} $out/bin/${meta.mainProgram} \
      --add-flags "-jar $out/share/java/$jarName"

    runHook postInstall
  '';

  meta = {
    description = "A RESTful directory services for a list channels";
    homepage = "https://channelfinder.readthedocs.io/en/latest/";
    mainProgram = "channel-finder-service";
    license = lib.licenses.mit;
    maintainers = with epnixLib.maintainers; [ minijackson ];
    inherit (jdk21.meta) platforms;
  };
}
