epnixLib: final: prev:
with prev;
  recurseIntoAttrs rec {
    inherit epnixLib;

    mkEpicsPackage = callPackage ./build-support/mk-epics-package.nix {};

    epnix = recurseIntoAttrs rec {
      epics-base7 = callPackage ./epnix/epics-base {
        version = "7.0.6";
        sha256 = "sha256-5s6tpT11I/unWLH1jt/MubRzZf3Q8LcADu11KZ3cmqw=";
      };
      epics-base3 = callPackage ./epnix/epics-base {
        version = "3.15.9";
        sha256 = "sha256-QWScmCEaG0F6OW6LPCaFur4W57oRl822p7wpzbYhOuA=";
      };
      epics-base = epics-base7;
      support = recurseIntoAttrs {
        asyn = callPackage ./epnix/support/asyn {};
        calc = callPackage ./epnix/support/calc {};
        epics-systemd = callPackage ./epnix/support/epics-systemd {};
        ipac = callPackage ./epnix/support/ipac {};
        modbus = callPackage ./epnix/support/modbus {};
        seq = callPackage ./epnix/support/seq {};
        sscan = callPackage ./epnix/support/sscan {};
        StreamDevice = callPackage ./epnix/support/StreamDevice {};
      };

      procServ = callPackage ./epnix/tools/procServ {};
    };
  }
