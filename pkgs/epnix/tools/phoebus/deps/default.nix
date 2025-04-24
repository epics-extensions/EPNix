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
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "ControlSystemStudio";
    repo = "phoebus";
    rev = "v5.0.0";
    hash = "sha256-Ig5l3WlO6cqJ9Xpo1DwpKLbAeZlCOFYCID4S1fsaCmA=";
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
  outputHash = "sha256-YQsL1EbqyDHtlqXm4C3NmMpqq6LDZzhhjtQfwcB6yfs=";

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
