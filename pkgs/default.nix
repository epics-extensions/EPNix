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

    # TODO: remove once every package uses the EPNix scope
    mkEpicsPackage = callPackage ./by-name/mkEpicsPackage/package.nix {};

    pythonPackagesExtensions =
      prev.pythonPackagesExtensions
      ++ [(final: _prev: importByName ./python-modules/by-name final)];

    linuxKernel =
      prev.linuxKernel
      // {
        packagesFor = kernel:
          (prev.linuxKernel.packagesFor kernel).extend (final: _prev: {
            mrf = final.callPackage ./epnix/kernel-modules/mrf {};
          });
      };

    epnix = scope prev (self:
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

        # EPICS support modules

        support = scope self (self:
          {
            reccaster = callPackage ./epnix/support/reccaster {};
            seq = callPackage ./epnix/support/seq {};
            snmp = callPackage ./epnix/support/snmp {};
            sscan = callPackage ./epnix/support/sscan {};
            twincat-ads = callPackage ./epnix/support/twincat-ads {};
          }
          // (importByName ./support/by-name self));

        # Lewis needs Python < 3.12
        inherit (final.python311Packages) lewis;

        inherit (final.python3Packages) pyepics;

        pythonSoftIOC = final.python3Packages.softioc;

        inherit (self.callPackage ./python-modules/by-name/lewis/lib.nix {}) mkLewisSimulator;

        # EPNix specific packages
        ci-scripts = scope self (_self: {
          build-docs-multiversion = callPackage ./ci-scripts/build-docs-multiversion.nix {};
        });
      }
      // (importByName ./by-name self));
  }
