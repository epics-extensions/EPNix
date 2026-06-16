{
  lib,
  epnixLib,
  fetchFromGitHub,
  jdk21,
  maven,
}:
maven.buildMavenPackage rec {
  pname = "pvws";
  version = "R4";

  src = fetchFromGitHub {
    owner = "ornl-epics";
    repo = "pvws";
    tag = version;
    hash = "sha256-ash9HDGmybhgKVOG5+LNeEsBSNklu81yglUILp87z8A=";
  };

  buildOffline = true;
  mvnJdk = jdk21;
  mvnHash = "sha256-QQQicKxjPsmWXyImOfWBL/4ySvrobdlXhGm7wBzvNog=";
  mvnParameters = "-Dproject.build.outputTimestamp=1980-01-01T00:00:02Z";

  installPhase = ''
    runHook preInstall

    install -Dt $out/webapps target/pvws.war
    install -Dt $out/share/doc/pvws LICENSE README.md

    runHook postInstall
  '';

  meta = {
    description = "Web Socket for PVs";
    homepage = "https://github.com/ornl-epics/pvws";
    license = lib.licenses.bsd3;
    maintainers = with epnixLib.maintainers; [ minijackson ];
    inherit (jdk21.meta) platforms;
  };
}
