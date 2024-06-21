{
  stdenv,
  lib,
  epnixLib,
  fetchFromGitHub,
  jdk,
  maven,
}:
stdenv.mkDerivation {
  pname = "phoebus-deps";
  version = "4.7.3";

  src = fetchFromGitHub {
    owner = "ControlSystemStudio";
    repo = "phoebus";
    rev = "v4.7.3";
    hash = "sha256-1Q66iZ+mTXzQ9pjW5wypG7q7rPy9K+PUcQXsKKk2sNo=";
  };

  nativeBuildInputs = [jdk maven];

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

    mvn package -Dmaven.javadoc.skip=true -Dmaven.source.skip=true -DskipTests -Dmaven.repo.local=$out

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
  outputHash = "sha256-tJMULUSwH0rCmNeKvesPqMVTBH3PQWInx6gzGxwdPwY=";

  doCheck = false;

  meta = {
    description = "Maven repo of all Phoebus dependencies";
    homepage = "https://github.com/ControlSystemStudio/phoebus/";
    license = lib.licenses.epl10;
    maintainers = with epnixLib.maintainers; [minijackson];
    inherit (jdk.meta) platforms;
    hidden = true;
  };
}
