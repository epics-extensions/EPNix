{
  lib,
  epnixLib,
  maven,
  fetchFromGitHub,
  makeWrapper,
  jre,
  nix-update-script,
}:

maven.buildMavenPackage (finalAttrs: {
  pname = "tomcat-jakartaee-migration";
  version = "1.0.13";
  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "apache";
    repo = "tomcat-jakartaee-migration";
    tag = finalAttrs.version;
    hash = "sha256-0yqE88meMQL/VI7QuaOp6EdkNtMz7QPC3c4brH6KGmw=";
  };

  mvnHash = "sha256-El2hmVDO/pUB7jTik6X2xcDqYKyNu9io6jOyWLv5h+U=";

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    install -TDm644 target/jakartaee-migration-*-shaded.jar $out/share/tomcat-jakartaee-migration/jakartaee-migration-shaded.jar

    mkdir -p $out/bin
    makeWrapper ${jre}/bin/java $out/bin/${finalAttrs.meta.mainProgram} \
      --add-flags "-jar $out/share/tomcat-jakartaee-migration/jakartaee-migration-shaded.jar"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Apache Tomcat migration tool for Jakarta EE";
    homepage = "https://github.com/apache/tomcat-jakartaee-migration";
    changelog = "https://github.com/apache/tomcat-jakartaee-migration/blob/${finalAttrs.src.rev}/CHANGES.md";
    license = lib.licenses.asl20;
    maintainers = with epnixLib.maintainers; [ minijackson ];
    mainProgram = "tomcat-jakartaee-migration";
    platforms = lib.platforms.all;
  };
})
