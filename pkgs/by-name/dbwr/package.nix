{
  lib,
  epnixLib,
  fetchFromGitHub,
  jdk21,
  maven,
}:
maven.buildMavenPackage rec {
  pname = "dbwr";
  version = "R1";

  src = fetchFromGitHub {
    owner = "ornl-epics";
    repo = pname;
    tag = version;
    hash = "sha256-pyJsp3qhj1B3SEvTbFzDW3MF18d0yijdJXuM3IJJqW8=";
  };

  buildOffline = true;
  mvnJdk = jdk21;
  mvnHash = "sha256-JKnz/ABRQLrwYE7dTFn2dFNSmjGH1wLZ2ApuHgNr0dU=";
  mvnParameters = "-Dproject.build.outputTimestamp=1980-01-01T00:00:02Z";

  installPhase = ''
    runHook preInstall

    install -Dt $out/webapps target/dbwr.war
    install -Dt $out/share/doc/dbwr LICENSE Readme.md

    runHook postInstall
  '';

  meta = {
    description = "Display Builder Web Runtime: Use many display builder screens in a web browser";
    homepage = "https://github.com/ornl-epics/dbwr";
    license = lib.licenses.bsd3;
    maintainers = with epnixLib.maintainers; [ minijackson ];
    inherit (jdk21.meta) platforms;
  };
}
