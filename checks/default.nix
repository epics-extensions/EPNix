{pkgs} @ args:
with pkgs.lib;
  {
    support-StreamDevice-simple = import ./support/StreamDevice/simple args;
  }
  // (let
    checkCrossFor = arch: import ./cross/default.nix (args // {crossArch = arch;});
  in (listToAttrs (map (arch:
      nameValuePair "cross-for-${arch}" (checkCrossFor arch))
    [
      "x86_64-linux"
      # Would be nice to have, but needs special care
      # "x86_64-w64-mingw32"
      # "x86_64-cygwin"
      "powerpc64-linux"
      "powerpc64le-linux"
      "aarch64-linux"
      # Needs special care
      # "armv6l-linux"
    ])))
