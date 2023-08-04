# TODO: upstream
{
  lib,
  stdenv,
  fetchurl,
  jdk,
}:
stdenv.mkDerivation (self: {
  pname = "mariadb-connector-java";
  version = "3.1.4";

  src = fetchurl {
    url = "https://dlm.mariadb.com/2912798/Connectors/java/connector-java-${self.version}/mariadb-java-client-${self.version}.jar";
    hash = "sha256-64i11yfYLiURfitvq87B2vc0YzsKV2RWxzIViEwYmtQ=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/java
    cp $src $out/share/java/mariadb-java-client.jar

    runHook postInstall
  '';

  meta = {
    description = "Connect applications developed in Java to MariaDB and MySQL databases";
    homepage = "https://github.com/mariadb-corporation/mariadb-connector-j";
    license = lib.licenses.lgpl21Only;
    maintainers = with lib.maintainers; [minijackson];
    sourceProvenance = with lib.sourceTypes; [binaryBytecode];
    inherit (jdk.meta) platforms;
  };
})
