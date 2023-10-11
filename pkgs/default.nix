epnixLib: final: prev:
with prev;
  recurseIntoAttrs rec {
    inherit epnixLib;

    mkEpicsPackage = callPackage ./build-support/mk-epics-package.nix {};

    epnix = recurseIntoAttrs rec {
      # EPICS base

      epics-base7 = callPackage ./epnix/epics-base {
        version = "7.0.7";
        hash = "sha256-VMiuwTuPykoMLcIphUAsjtLQZ8HLKr3LvGpje3lsIXc=";
      };
      epics-base3 = callPackage ./epnix/epics-base {
        version = "3.15.9";
        hash = "sha256-QWScmCEaG0F6OW6LPCaFur4W57oRl822p7wpzbYhOuA=";
      };
      epics-base = epics-base7;

      # EPICS support modules

      support = recurseIntoAttrs {
        asyn = callPackage ./epnix/support/asyn {};
        autosave = callPackage ./epnix/support/autosave {};
        calc = callPackage ./epnix/support/calc {};
        epics-systemd = callPackage ./epnix/support/epics-systemd {};
        ipac = callPackage ./epnix/support/ipac {};
        modbus = callPackage ./epnix/support/modbus {};
        seq = callPackage ./epnix/support/seq {};
        snmp = callPackage ./epnix/support/snmp {};
        sscan = callPackage ./epnix/support/sscan {};
        StreamDevice = callPackage ./epnix/support/StreamDevice {};
      };

      # EPICS related tools and extensions

      archiver-appliance = callPackage ./epnix/tools/archiver-appliance {};

      ca-gateway = callPackage ./epnix/tools/ca-gateway {};

      pcas = callPackage ./epnix/tools/pcas {};

      phoebus = callPackage ./epnix/tools/phoebus/client {
        # TODO: uncomment when this works:
        # TODO: add libjfxwebkit.so into openjfx
        # jdk = final.openjdk17.override {enableJavaFX = true;};
      };
      phoebus-alarm-server = callPackage ./epnix/tools/phoebus/alarm-server {};
      phoebus-alarm-logger = callPackage ./epnix/tools/phoebus/alarm-logger {};
      phoebus-archive-engine = callPackage ./epnix/tools/phoebus/archive-engine {};
      phoebus-deps = callPackage ./epnix/tools/phoebus/deps {};
      phoebus-olog = callPackage ./epnix/tools/phoebus/olog {};
      phoebus-pva = callPackage ./epnix/tools/phoebus/pva {};
      phoebus-save-and-restore = callPackage ./epnix/tools/phoebus/save-and-restore {};
      phoebus-scan-server = callPackage ./epnix/tools/phoebus/scan-server {};
      phoebus-setup-hook = callPackage ./epnix/tools/phoebus/setup-hook {};
      procServ = callPackage ./epnix/tools/procServ {};

      # Other utilities

      mariadb_jdbc = callPackage ./epnix/tools/mariadb_jdbc {};

      # EPNix specific packages
      book = callPackage ./book {};
      manpages = callPackage ./manpages {};
    };
  }
