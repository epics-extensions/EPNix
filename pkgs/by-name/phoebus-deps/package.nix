{
  stdenv,
  lib,
  epnixLib,
  fetchFromGitHub,
  jdk21,
  maven,
}:
stdenv.mkDerivation (final: {
  pname = "phoebus-deps";
  version = "5.0.2";

  src = fetchFromGitHub {
    owner = "ControlSystemStudio";
    repo = "phoebus";
    rev = "v${final.version}";
    hash = "sha256-k0zURg5b0NyTsMaHYLYAmzNtFYAFHafW+gRutUgCqto=";
  };

  nativeBuildInputs = [
    jdk21
    maven
  ];

  MAVEN_OPTS = "-Xmx1G";

  # Because maven downloads dependencies only when needed, we build the whole
  # project once, just to have the maven repository as output. Then, the
  # "downstream" packages (phoebus-client, phoebus-alarm-server, etc.) build
  # their own respective parts using this repository, again, but without access
  # to the network, which has stronger reproducibilité guarantees.
  #
  # Although it would be better, the mvn2nix-maven-plugin was tried, but the
  # generated repository wasn't enough for Phoebus...
  buildPhase = ''
    runHook preBuild

    mvn package -Dmaven.javadoc.skip=true -Dmaven.source.skip=true -Dmaven.test.skip -Dmaven.repo.local=$out

    runHook postBuild
  '';

  # keep only *.{pom,jar,sha1,nbm} and delete all ephemeral files with
  # lastModified timestamps inside
  installPhase = ''
    runHook preInstall

    echo "Removing impure files"
    find $out \
      \( \
      -type f \
      -name \*.lastUpdated -or \
      -name resolver-status.properties -or \
      -name _remote.repositories -or \
      -name maven-metadata-local.xml \
      \) \
      -delete

    runHook postInstall
  '';

  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
  outputHash = "sha256-FDfqTa0WucRTTEh49ZDfCaNxTPokpoAL17OTBI4Z7xY=";

  doCheck = false;

  meta = {
    description = "Maven repo of all Phoebus dependencies";
    homepage = "https://github.com/ControlSystemStudio/phoebus/";
    license = lib.licenses.epl10;
    maintainers = with epnixLib.maintainers; [ minijackson ];
    inherit (jdk21.meta) platforms;
    hidden = true;
  };
})
