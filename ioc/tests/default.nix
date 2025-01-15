{
  nixpkgs,
  pkgs,
  self,
  system,
} @ args: let
  inherit (pkgs) lib;

  nixosTesting = import (nixpkgs + "/nixos/lib/testing-python.nix") {
    inherit pkgs system;
    extraConfigurations = [
      self.nixosModules.nixos
    ];
  };

  handleTest = path: args: nixosTesting.simpleTest (import path (pkgs // args));
in
  {
    default-ioc-epics-base-3 = handleTest ./default-ioc {releaseBranch = "3";};
    default-ioc-epics-base-7 = handleTest ./default-ioc {releaseBranch = "7";};
    example-ioc = handleTest ./example-ioc {};

    pyepics = handleTest ./pyepics {};

    support-autosave-simple = handleTest ./support/autosave/simple {};
    support-pvxs-ioc = handleTest ./support/pvxs/ioc {};
    support-pvxs-qsrv2 = handleTest ./support/pvxs/qsrv2 {};
    support-pvxs-standalone-server = handleTest ./support/pvxs/standalone-server {};
    support-seq-simple = import ./support/seq/simple args;
    support-StreamDevice-simple = import ./support/StreamDevice/simple args;
  }
  // (let
    checkCrossFor = crossSystem: let
      system-name = (lib.systems.elaborate crossSystem).system;
    in
      lib.nameValuePair
      "cross-for-${system-name}"
      (import ./cross/default.nix (args // {inherit crossSystem system-name;}));

    systemsToCheck = with lib.systems.examples; [
      # Maybe one day...
      #mingwW64

      # IFC1410
      # This is commented out now, due to an issue from Qemu
      # The tests don't pass, but they run on actual hardware
      #ppc64

      powernv

      # D-TACQ
      {system = "armv7a-linux";}

      aarch64-multiplatform
      raspberryPi
    ];
  in
    lib.listToAttrs (map checkCrossFor systemsToCheck))
