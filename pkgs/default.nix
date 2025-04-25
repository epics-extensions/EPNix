epnixLib: inputs: final: prev: let
  inherit (final) callPackage;
  # From prev, else it somehow causes an infinite recursion
  inherit (prev) recurseIntoAttrs lib;
  scope = prev: f: recurseIntoAttrs (lib.makeScope prev.newScope f);

  importByName = baseDirectory: self:
    lib.pipe baseDirectory [
      builtins.readDir
      (lib.filterAttrs (_: type: type == "directory"))
      # Call the packages
      (lib.mapAttrs (name: _type: self.callPackage (baseDirectory + "/${name}/package.nix") {}))
    ];
in
  recurseIntoAttrs {
    inherit epnixLib;

    mkEpicsPackage = callPackage ./build-support/mk-epics-package {};

    pythonPackagesExtensions =
      prev.pythonPackagesExtensions
      ++ [
        (final: prev: {
          lewis = final.callPackage ./epnix/tools/lewis {};
          channelfinder = final.callPackage ./epnix/tools/channel-finder/pyCFClient {};
          pyepics = final.callPackage ./epnix/python-modules/pyepics {};
          recceiver = final.callPackage ./epnix/tools/channel-finder/recceiver {};
          scanf = final.callPackage ./epnix/tools/scanf {};
          epicscorelibs = final.callPackage ./epnix/python-modules/epicscorelibs {};
          pvxslibs = final.callPackage ./epnix/python-modules/pvxslibs {};
          aioca = final.callPackage ./epnix/python-modules/aioca/default.nix {};
          epicsdbbuilder = final.callPackage ./epnix/python-modules/epicsdbbuilder {};
          softioc = final.callPackage ./epnix/python-modules/softioc {};
          p4p = final.callPackage ./epnix/python-modules/p4p {};
        })
      ];

    linuxKernel =
      prev.linuxKernel
      // {
        packagesFor = kernel:
          (prev.linuxKernel.packagesFor kernel).extend (final: _prev: {
            mrf = final.callPackage ./epnix/kernel-modules/mrf {};
          });
      };

    epnix = scope prev (self: let
      epnixScope = self;
    in
      {
        # EPICS base

        epics-base7 = callPackage ./epnix/epics-base {
          version = "7.0.9";
          hash = "sha256-RPlJhh7ORobYlM7gq6uDZkrO5z579Q7hyLEQ1xiHvFY=";
        };
        epics-base3 = callPackage ./epnix/epics-base {
          version = "3.15.9";
          hash = "sha256-QWScmCEaG0F6OW6LPCaFur4W57oRl822p7wpzbYhOuA=";
        };
        epics-base = self.epics-base7;

        epicsSetupHook = callPackage ./build-support/epics-setup-hook {};

        # EPICS support modules

        support = scope self (self: {
          adsDriver = callPackage ./epnix/support/adsDriver {};
          asyn = callPackage ./epnix/support/asyn {};
          autoparamDriver = callPackage ./epnix/support/autoparamDriver {};
          autosave = callPackage ./epnix/support/autosave {};
          busy = callPackage ./epnix/support/busy {};
          calc = callPackage ./epnix/support/calc {};
          devlib2 = callPackage ./epnix/support/devlib2 {};
          epics-systemd = callPackage ./epnix/support/epics-systemd {};
          gtest = callPackage ./epnix/support/gtest {};
          ipac = callPackage ./epnix/support/ipac {};
          modbus = callPackage ./epnix/support/modbus {};
          mrfioc2 = callPackage ./epnix/support/mrfioc2 {};
          opcua = callPackage ./epnix/support/opcua {open62541 = epnixScope.open62541_1_3;};
          pvxs = callPackage ./epnix/support/pvxs {};
          reccaster = callPackage ./epnix/support/reccaster {};
          seq = callPackage ./epnix/support/seq {};
          snmp = callPackage ./epnix/support/snmp {};
          sscan = callPackage ./epnix/support/sscan {};
          StreamDevice = callPackage ./epnix/support/StreamDevice {};
          twincat-ads = callPackage ./epnix/support/twincat-ads {};
        });

        # EPICS related tools and extensions

        archiver-appliance = callPackage ./epnix/tools/archiver-appliance {
          jdk = prev.jdk17;
        };

        # Lewis needs Python < 3.12
        inherit (final.python311Packages) lewis;

        inherit (final.python3Packages) pyepics;

        pythonSoftIOC = final.python3Packages.softioc;

        inherit (callPackage ./epnix/tools/lewis/lib.nix {}) mkLewisSimulator;

        phoebus = callPackage ./epnix/tools/phoebus/client {};

        # Other utilities

        # Needed by support/opcua
        open62541_1_3 = callPackage ./epnix/tools/open62541_1_3 {};

        # EPNix specific packages
        docs = callPackage ./docs {
          nixdomainLib = inputs.sphinxcontrib-nixdomain.lib;
        };

        # Documentation support packages
        psu-simulator = callPackage ./doc-support/psu-simulator {};

        ci-scripts = scope self (_self: {
          build-docs-multiversion = callPackage ./ci-scripts/build-docs-multiversion.nix {};
        });
      }
      // (importByName ./by-name self));
  }
