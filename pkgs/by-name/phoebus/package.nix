{
  stdenv,
  lib,
  phoebus-unwrapped,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  settingsFile ? null,
  # Inspired by:
  # https://epics.anl.gov/tech-talk/2024/msg00895.php
  java_opts ? "-XX:MinHeapSize=128m -XX:MaxHeapSize=4g -XX:InitialHeapSize=1g -XX:MaxHeapFreeRatio=10 -XX:MinHeapFreeRatio=5 -XX:-ShrinkHeapInSteps -XX:NativeMemoryTracking=detail",
}:
stdenv.mkDerivation {
  pname = "phoebus";
  inherit (phoebus-unwrapped) version;
  nativeBuildInputs = [makeWrapper copyDesktopItems];

  dontUnpack = true;
  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    # This wrapper for the `phoebus-unwrapped` executable sets the `JAVA_OPTS`
    makeWrapper "${lib.getExe phoebus-unwrapped}" "$out/bin/$pname" \
      ${lib.optionalString (settingsFile != null) ''--add-flags "-settings ${settingsFile}"''} \
      --prefix JAVA_OPTS " " "${java_opts}"

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

  inherit (phoebus-unwrapped) meta;
}
