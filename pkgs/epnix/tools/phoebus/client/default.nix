{
  lib,
  epnixLib,
  stdenv,
  maven,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  epnix,
  jdk,
}: let
  buildDate = "2022-02-24T07:56:00Z";
in
  stdenv.mkDerivation {
    pname = "phoebus";
    inherit (epnix.phoebus-deps) version src;

    # TODO: make a scope, so that we don't pass around the whole `epnix`
    nativeBuildInputs = [
      maven
      copyDesktopItems
      makeWrapper
      (epnix.phoebus-setup-hook.override {jdk = jdk.override {enableJavaFX = true;};})
    ];

    desktopItems = [
      (makeDesktopItem {
        name = "phoebus";
        exec = "phoebus -server 4918 -resource %f";
        desktopName = "Phoebus";
        keywords = ["epics" "css"];
        categories = [
          "Office"
          "Graphics"
          "GUIDesigner"
          "Viewer"
          "Science"
          "Physics"
          "Monitor"
          "Java"
        ];
      })
    ];

    buildPhase = ''
      runHook preBuild

      # Copy deps to a writable directory, due to the usage of "install-jars"
      local deps=$PWD/deps
      cp -r --no-preserve=mode "${epnix.phoebus-deps}" $deps

      # TODO: tests fail
      mvn package \
        --projects "./phoebus-product" \
        --also-make \
        --offline \
        -Dmaven.javadoc.skip=true -Dmaven.source.skip=true -DskipTests \
        -Dproject.build.outputTimestamp=${buildDate} \
        -Dmaven.repo.local="$deps"

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      installPhoebusJar \
        "phoebus-product/" \
        "product-$version.jar" \
        "phoebus" \
        "org.phoebus.product.Launcher"

      # MIME types for PV Tables
      install -D -m 444 phoebus-product/phoebus.xml -t $out/share/mime/packages

      runHook postInstall
    '';

    meta = {
      description = "Control System Studio's Phoebus client";
      homepage = "https://control-system-studio.readthedocs.io/en/latest/index.html";
      license = lib.licenses.epl10;
      maintainers = with epnixLib.maintainers; [minijackson];
      inherit (jdk.meta) platforms;
    };
  }
