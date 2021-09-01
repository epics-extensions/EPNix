self: super:

with super;
recurseIntoAttrs rec {
  mkEpicsPackage = callPackage ./build-support/mk-epics-package.nix { };

  epnixLib = import ../lib { pkgs = super; lib = super.lib; };

  epics = recurseIntoAttrs {
    base = callPackage ./epics/base { };
    support = recurseIntoAttrs {
      asyn = callPackage ./epics/support/asyn { };
      calc = callPackage ./epics/support/calc { };
      ipac = callPackage ./epics/support/ipac { };
      seq = callPackage ./epics/support/seq { };
      sscan = callPackage ./epics/support/sscan { };
      StreamDevice = callPackage ./epics/support/StreamDevice { };
    };
  };
}
