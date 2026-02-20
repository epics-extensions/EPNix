epnixLib: inputs: final: prev:
let
  inherit (final) callPackage;
  # From prev, else it somehow causes an infinite recursion
  inherit (prev) recurseIntoAttrs lib;
  scope = prev: f: recurseIntoAttrs (lib.makeScope prev.newScope f);

  importByName =
    baseDirectory: self:
    lib.pipe baseDirectory [
      builtins.readDir
      (lib.filterAttrs (_: type: type == "directory"))
      # Call the packages
      (lib.mapAttrs (name: _type: self.callPackage (baseDirectory + "/${name}/package.nix") { }))
    ];
in
recurseIntoAttrs {
  inherit epnixLib;

  # TODO: remove once every package uses the EPNix scope
  mkEpicsPackage = callPackage ./by-name/mkEpicsPackage/package.nix { };

  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (final: _prev: importByName ./python-modules/by-name final)
  ];

  linuxKernel = prev.linuxKernel // {
    packagesFor =
      kernel:
      (prev.linuxKernel.packagesFor kernel).extend (
        final: _prev: {
          mrf = final.callPackage ./kernel-modules/mrf { };
        }
      );
  };

  epnix = scope prev (
    self:
    {
      # EPICS base

      epics-base7 = self.callPackage ./epics-base {
        version = "7.0.10";
        hash = "sha256-78XAznaU4gxIc13GKrtpil96OPhQ/JTuJm8aVIfUSho=";
      };
      epics-base3 = self.callPackage ./epics-base {
        version = "3.15.9";
        hash = "sha256-QWScmCEaG0F6OW6LPCaFur4W57oRl822p7wpzbYhOuA=";
      };
      epics-base = self.epics-base7;

      # EPICS support modules

      support = scope self (self: importByName ./support/by-name self);

      # Lewis needs Python < 3.12
      inherit (final.python311Packages) lewis;

      inherit (final.python3Packages) pyepics;

      pythonSoftIOC = final.python3Packages.softioc;

      inherit (self.callPackage ./python-modules/by-name/lewis/lib.nix { }) mkLewisSimulator;

      # EPNix specific packages
      ci-scripts = scope self (self: importByName ./ci-scripts/by-name self);
    }
    // (importByName ./by-name self)
  );
}
