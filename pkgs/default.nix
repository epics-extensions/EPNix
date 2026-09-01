epnixLib: final: prev:
let
  inherit (final) callPackage;
  # From prev, else it somehow causes an infinite recursion
  inherit (prev) lib;

  pythonPackages =
    self:
    lib.packagesFromDirectoryRecursive {
      inherit (self) callPackage newScope;
      directory = ./python-modules/by-name;
    };

  linuxPackages =
    self:
    lib.recurseIntoAttrs (
      lib.packagesFromDirectoryRecursive {
        inherit (self) callPackage;
        directory = ./kernel-modules/by-name;
      }
    );
in
lib.recurseIntoAttrs {
  inherit epnixLib;

  mkEpicsPackage = callPackage ./by-name/mkEpicsPackage/package.nix { };

  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (f: _prev: pythonPackages f)
  ];

  linuxKernel = prev.linuxKernel // {
    packagesFor = kernel: (prev.linuxKernel.packagesFor kernel).extend (f: _prev: linuxPackages f);
  };

  # All EPNix packages defined in scopes outside of `pkgs.epnix`,
  # but only their "default" implementation (for example `python3Packages` or `linuxPackages`)
  epnixOutsideDefaultScopes = {
    python3Packages = pythonPackages final.python3Packages;
    linuxPackages = linuxPackages final.linuxPackages;
  };

  # TODO: `recurseIntoAttrs` shouldn't be necessary here,
  # waiting on: https://github.com/NixOS/nixpkgs/pull/557276
  epnix = lib.recurseIntoAttrs (
    (lib.packagesFromDirectoryRecursive {
      inherit (final) callPackage newScope;
      directory = ./by-name;
    }).overrideScope
      (
        epnixFinal: _epnixPrev: {
          epics-base7 = epnixFinal.callPackage ./epics-base {
            version = "7.0.10";
            hash = "sha256-78XAznaU4gxIc13GKrtpil96OPhQ/JTuJm8aVIfUSho=";
          };
          epics-base3 = epnixFinal.callPackage ./epics-base {
            version = "3.15.9";
            hash = "sha256-QWScmCEaG0F6OW6LPCaFur4W57oRl822p7wpzbYhOuA=";
          };
          epics-base = epnixFinal.epics-base7;

          # Reexported python packages
          inherit (final.python3Packages) lewis pyepics;
          pythonSoftIOC = final.python3Packages.softioc;

          # Reexported functions
          # TODO: remove in release 27.05
          mkLewisSimulator =
            arg:
            lib.warn "epnix.mkLewisSimulator was renamed to epnix.lewis.mkSimulator and will be removed in release nixos-27.05" (
              epnixFinal.lewis.passthru.mkSimulator arg
            );
        }
      )
  );
}
