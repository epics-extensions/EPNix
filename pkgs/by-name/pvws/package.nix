{
  lib,
  epnixLib,
  fetchFromGitHub,
  jdk21,
  maven,
}:
maven.buildMavenPackage rec {
  pname = "pvws";
  version = "R3";

  src = fetchFromGitHub {
    owner = "ornl-epics";
    repo = pname;
    tag = version;
    hash = "sha256-XuYXiHBsbcwsOekWqgtVBzjgCChczjiW4EOPo5LJAP0=";
  };

  buildOffline = true;
  mvnJdk = jdk21;
  mvnHash = "sha256-bNlB2T0+ZxgpyGO7cusA19Fld7ZRU65utKVj88PaVMs=";
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
