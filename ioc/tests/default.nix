{pkgs, ...} @ args:
with pkgs.lib;
  {
    default-ioc-epics-base-3 = import ./default-ioc "3" args;
    default-ioc-epics-base-7 = import ./default-ioc "7" args;

    pyepics = import ./pyepics args;

    support-autosave-simple = import ./support/autosave/simple args;
    support-pvxs-ioc = import ./support/pvxs/ioc args;
    support-pvxs-qsrv2 = import ./support/pvxs/qsrv2 args;
    support-pvxs-standalone-server = import ./support/pvxs/standalone-server args;
    support-seq-simple = import ./support/seq/simple args;
    support-StreamDevice-simple = import ./support/StreamDevice/simple args;
  }
  // (let
    checkCrossFor = crossSystem: let
      system-name = (systems.elaborate crossSystem).system;
    in
      nameValuePair
      "cross-for-${system-name}"
      (import ./cross/default.nix (args // {inherit crossSystem system-name;}));

    systemsToCheck = with systems.examples; [
      # Maybe one day...
      #mingwW64

      # IFC1410
      # This is commented out now, due to an issue from Qemu
      # The tests don't pass, but they run on actual hardware
      #ppc64

      powernv

      # D-TACQ
      {system = "armv7a-linux";}

      raspberryPi
    ];
  in
    listToAttrs (map checkCrossFor systemsToCheck))
