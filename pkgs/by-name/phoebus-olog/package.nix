{
  lib,
  epnixLib,
  fetchFromGitHub,
  jdk21,
  maven,
  makeWrapper,
}:
maven.buildMavenPackage rec {
  pname = "phoebus-olog";
  version = "5.1.2";

  src = fetchFromGitHub {
    owner = "Olog";
    repo = "phoebus-olog";
    tag = "v${version}";
    hash = "sha256-5LcDBisr+uu43B3WwwzDNFNVfchuZb9shWDipgGIo2Q=";
  };

  mvnJdk = jdk21;
  mvnHash = "sha256-6I+d6XEd6XYMZVaWyhk6YPBWAf3DnF8Xh2fDdxV7xk0=";
  mvnParameters = "-Dmaven.javadoc.skip=true -Dmaven.source.skip=true -Pdeployable-jar";

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/share/java

    jarName="service-olog-${version}.jar"

    install -Dm644 target/service-olog-${version}.jar $out/share/java

    makeWrapper ${lib.getExe jdk21} $out/bin/${meta.mainProgram} \
      --add-flags "-jar $out/share/java/$jarName"

    runHook postInstall
  '';

  meta = {
    description = "Online logbook for experimental and industrial logging";
    homepage = "https://olog.readthedocs.io/en/latest/";
    mainProgram = "phoebus-olog";
    license = lib.licenses.epl10;
    maintainers = with epnixLib.maintainers; [ minijackson ];
    inherit (jdk21.meta) platforms;
  };
}
