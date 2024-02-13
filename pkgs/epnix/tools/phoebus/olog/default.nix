{
  lib,
  epnixLib,
  stdenv,
  fetchFromGitHub,
  maven,
  libfaketime,
  canonicalize-jars-hook,
  jdk,
  git,
  makeWrapper,
}: let
  # TODO: upstream outputTimestamp
  buildDate = "2022-02-24T07:56:00Z";
  mvnOptions = "-Dmaven.javadoc.skip=true -Dmaven.source.skip=true -Pdeployable-jar -Dproject.build.outputTimestamp=${buildDate}";
in
  stdenv.mkDerivation (final: {
    pname = "phoebus-olog";
    version = "4.7.3";

    src = fetchFromGitHub {
      owner = "Olog";
      repo = "phoebus-olog";
      rev = "v${final.version}";
      hash = "sha256-WwRB4QtZBeH6GptTZJ02CBpP7BGzjZbwMYQrOmGevFo=";
    };

    deps = stdenv.mkDerivation {
      name = with final; "${pname}-${version}-deps";
      inherit (final) src;

      nativeBuildInputs = [jdk maven git];

      buildPhase = ''
        runHook preBuild

        # Don't use the launch script, we use the jar file as a jar
        mvn package ${mvnOptions} -Dmaven.repo.local=$out

        runHook postBuild
      '';

      # keep only *.{pom,jar,sha1,nbm} and delete all ephemeral files with
      # lastModified timestamps inside
      installPhase = ''
        runHook preInstall

        find $out -type f \
          -name \*.lastUpdated -or \
          -name resolver-status.properties -or \
          -name _remote.repositories \
          -delete

        runHook postInstall
      '';

      outputHashAlgo = "sha256";
      outputHashMode = "recursive";
      outputHash = "sha256-40n06R2KBuuzqvVq1bWsd1jjQtcNQfK/4RbgtFmxTf8=";

      doCheck = false;
    };

    nativeBuildInputs = [maven makeWrapper libfaketime];

    buildPhase = ''
      runHook preBuild

      # Use faketime because files inside the jar have an mtime
      faketime -f "1970-01-01 00:00:01" mvn package --offline ${mvnOptions} -Dmaven.repo.local="$deps"

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin
      mkdir -p $out/share/java

      jarName="service-olog-${final.version}.jar"

      classpath=$(find $deps -name "*.jar" -printf ':%h/%f');
      install -Dm644 target/service-olog-4.7.3.jar $out/share/java
      # Strip the script at the beginning of the jar, so that we are able to
      # canonicalize it
      sed -i '1,/^exit 0$/d' $out/share/java/$jarName

      makeWrapper ${jdk}/bin/java $out/bin/${final.pname} \
        --add-flags "-classpath ''${classpath#:}" \
        --add-flags "-jar $out/share/java/$jarName"

      runHook postInstall
    '';

    meta = {
      description = "Online logbook for experimental and industrial logging";
      homepage = "https://olog.readthedocs.io/en/latest/";
      license = lib.licenses.epl10;
      maintainers = with epnixLib.maintainers; [minijackson];
      inherit (jdk.meta) platforms;
    };
  })
