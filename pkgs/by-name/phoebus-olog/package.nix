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
  version = "5.0.4";

  src = fetchFromGitHub {
    owner = "Olog";
    repo = "phoebus-olog";
    rev = "v${version}";
    hash = "sha256-UudG3ltEZMOcMgwVNZJKdlaJZ9XsRaEsyKwqzcJ0yDs=";
  };

  patches = [ ./fix-deps-reproducibility.patch ];

  mvnHash = "sha256-xMiCU6k1cnlGUxqV35Qs20XOx9BMg7d5wPdNo6wTdHU=";
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
