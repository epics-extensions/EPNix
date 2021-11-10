epnixLib:

final: prev:

with prev;
recurseIntoAttrs rec {
  inherit epnixLib;

  mkEpicsPackage = callPackage ./build-support/mk-epics-package.nix { };

  epnix = recurseIntoAttrs {
    # TODO: rename into epics-base
    epics-base = callPackage ./epnix/epics-base { };
    support = {
      asyn = callPackage ./epnix/support/asyn { };
      calc = callPackage ./epnix/support/calc { };
      ipac = callPackage ./epnix/support/ipac { };
      seq = callPackage ./epnix/support/seq { };
      sscan = callPackage ./epnix/support/sscan { };
      StreamDevice = callPackage ./epnix/support/StreamDevice { };
    };
  };
}
