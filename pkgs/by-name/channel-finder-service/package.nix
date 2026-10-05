{
  lib,
  epnixLib,
  fetchFromGitHub,
  fetchpatch2,
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
    (fetchpatch2 {
      name = "support-github-archive.patch";
      url = "https://github.com/ChannelFinder/ChannelFinderService/commit/07d0b07764090d4cb593064511f45682d7eba6bb.patch?full_index=1";
      hash = "sha256-ZLf0LO+ytaJ5tqOSgIZ6LC3Fl3xn5BlDQaC6Zkfi4bU=";
    })
    (fetchpatch2 {
      name = "fix-maven-plugin-versions.patch";
      url = "https://github.com/ChannelFinder/ChannelFinderService/commit/216f5fa70f53ea66a8228378e2c667fba9b13292.patch?full_index=1";
      hash = "sha256-RPzxJsvdQ5JrnDbZPmbHWflmzSrRsl3naqvOG0QW93k=";
    })
    (fetchpatch2 {
      name = "fix-default-maven-plugin-versions.patch";
      url = "https://github.com/ChannelFinder/ChannelFinderService/commit/0823890a86d2a4e7094cef22b3b3e572f495aca7.patch?full_index=1";
      hash = "sha256-K2QtG7qedf6abegxVHi4AJ2+lJlOnN6LnyXnEzgATuI=";
    })
  ];

  buildOffline = true;
  mvnJdk = jdk25_headless;
  mvnHash = "sha256-q4zeziySBlAFOIZJmWuvoOdKdBgVgn+pAMhcMFz6nWU=";
  # Tests require setting up Elasticsearch and Docker
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
