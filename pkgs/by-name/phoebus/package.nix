{
  stdenv,
  lib,
  phoebus-unwrapped,
  makeWrapper,
  wrapGAppsHook3,
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
  nativeBuildInputs = [
    makeWrapper
    wrapGAppsHook3
    copyDesktopItems
  ];

  dontUnpack = true;
  dontBuild = true;
  dontConfigure = true;

  # Prevent double-wrapping
  dontWrapGApps = true;

  # Install things as expected by Phoebus,
  # see the usage of `Locations.install()` in the Phoebus repository.
  postInstall = ''
    mkdir $out

    # Settings file
    ${lib.optionalString (settingsFile != null) "ln -sfn ${settingsFile} $out/settings.ini"}
    # Documentation
    ln -sfn ${phoebus-unwrapped}/share/doc/${phoebus-unwrapped.name}/html $out/doc
  '';

  # Don't move `$out/doc` to the correct location,
  # leave it as-is.
  forceShare = "man info";

  # Not install phase,
  # because it's too early for "gappsWrapperArgs" to be populated
  fixupPhase = ''
    runHook preFixup

    # This wrapper for the `phoebus-unwrapped` executable sets the `JAVA_OPTS`
    makeWrapper "${lib.getExe phoebus-unwrapped}" "$out/bin/$pname" \
      ''${gappsWrapperArgs[@]} \
      --prefix JAVA_OPTS " " "-Dphoebus.install=$out" \
      --prefix JAVA_OPTS " " "${java_opts}"

    runHook postFixup
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "phoebus";
      exec = "phoebus -server 4918 -resource %f";
      desktopName = "Phoebus";
      keywords = [
        "epics"
        "css"
      ];
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
