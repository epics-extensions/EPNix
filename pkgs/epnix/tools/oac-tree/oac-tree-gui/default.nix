{
  stdenv,
  lib,
  epnix,
  symlinkJoin,
  oac-tree-gui-unwrapped,
  makeWrapper,
  plugins ? [],
}: let
  unwrapped = oac-tree-gui-unwrapped;
  pluginPath = lib.concatMapStringsSep ":" (plugin: "${plugin}/lib/oac-tree/plugins") plugins;
in
  symlinkJoin {
    pname = lib.replaceStrings ["-unwrapped"] [""] unwrapped.pname;
    inherit (unwrapped) version;

    paths = [unwrapped];

    nativeBuildInputs = [makeWrapper];

    postBuild = ''
      wrapProgram $out/bin/oac-tree-gui --prefix LD_LIBRARY_PATH : "${pluginPath}"

    '';
  }
