{
  makeWrapper,
  epnix,
  epnixLib,
  lib,
  makeDesktopItem,
  copyDesktopItems,
  stdenv,
  java_opts ? "-XX:MinHeapSize=128m -XX:MaxHeapSize=4g -XX:InitialHeapSize=1g -XX:MaxHeapFreeRatio=10 -XX:MinHeapFreeRatio=5 -XX:-ShrinkHeapInSteps -XX:NativeMemoryTracking=detail",
}:
stdenv.mkDerivation {
  pname = "phoebus";
  name = "phoebus";
  nativeBuildInputs = [makeWrapper copyDesktopItems];
  dontBuild = true;
  dontConfigure = true;
  dontUnpack = true;

  installPhase = ''

    runHook preInstall
    # This wrapper for the `phoebus-unwrapped` executable sets the `JAVA_OPTS`
    #environment variable with the provided `java_opts` value.

    makeWrapper "${lib.getExe epnix.phoebus-unwrapped}" "$out/bin/$name" \
    --prefix JAVA_OPTS ":" "${java_opts}"
    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "phoebus";
      exec = "phoebus -server 4918 -resource %f";
      desktopName = "Phoebus";
      keywords = ["epics" "css"];
      # https://specifications.freedesktop.org/menu-spec/menu-spec-1.0.html#category-registry
      categories = [
        # Main
        "Office"

        # Additional
        "Java"
        "Viewer"
      ];
    })
  ];
  meta = {
    inherit (epnix.phoebus-unwrapped.meta) description;
    inherit (epnix.phoebus-unwrapped.meta) homepage;
    inherit (epnix.phoebus-unwrapped.meta) platforms;
    inherit (epnix.phoebus-unwrapped.meta) license;
    inherit (epnix.phoebus-unwrapped.meta) maintainers;
    inherit (epnix.phoebus-unwrapped.meta) mainProgram;
  };
}
