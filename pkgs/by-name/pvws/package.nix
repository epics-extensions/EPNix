{
  lib,
  epnixLib,
  fetchFromGitHub,
  jdk21_headless,
  maven,
  makeWrapper,
}:
maven.buildMavenPackage rec {
  pname = "pvws";
  version = "R4-unstable-2026-11-05";

  src = fetchFromGitHub {
    owner = "ControlSystemStudio";
    repo = "pvws";
    rev = "d86e154bc8338094ae2a0add0cbc49f45f21af0c";
    hash = "sha256-Z1c0hP12hxnriV0Qv/X2JlGK7xw3z4bDzLHwKPTnR+I=";
  };

  buildOffline = true;
  mvnJdk = jdk21_headless;
  mvnHash = "sha256-fTQ5F9bzOnEHDk608aWXoUaBapGoL/SRmpRlY2tOgR8=";
  mvnParameters = "-Dproject.build.outputTimestamp=1980-01-01T00:00:02Z";

  # Dynamic test dependencies
  # which aren't picked up by go-offline-maven-plugin
  manualMvnArtifacts = [
    # "org.springframework.boot:spring-boot-maven-plugin:4.0.0-RC1"
    "org.apache.maven.surefire:surefire-junit-platform:3.5.6"
    "org.junit.platform:junit-platform-launcher:6.0.3"
    # "org.jacoco:org.jacoco.agent:0.8.10:jar:runtime"
  ];

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    install -m644 -Dt $out/share/java target/pvws.jar{,.original}
    # TODO: ask where the LICENSE has gone?
    #install -Dt $out/share/doc/pvws LICENSE README.md

    makeWrapper ${lib.getExe jdk21_headless} $out/bin/${meta.mainProgram} \
      --add-flags "-jar $out/share/java/pvws.jar"

    runHook postInstall
  '';

  meta = {
    description = "Web Socket for PVs";
    homepage = "https://github.com/ornl-epics/pvws";
    mainProgram = "pvws";
    license = lib.licenses.bsd3;
    maintainers = with epnixLib.maintainers; [ minijackson ];
    inherit (jdk21_headless.meta) platforms;
  };
}
