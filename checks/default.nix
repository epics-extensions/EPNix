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
      "powerpc64-unknown-linux-gnu"
      "powerpc64le-unknown-linux-gnu"
      "aarch64-unknown-linux-gnu"
      # Needs special care
      # "armv6l-linux"
    ])))
