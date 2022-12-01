{pkgs, ...} @ args:
with pkgs.lib;
  {
    support-seq-simple = import ./support/seq/simple args;
    support-StreamDevice-simple = import ./support/StreamDevice/simple args;
  }
  // (let
    checkCrossFor = crossSystem: let
      system-name = (systems.elaborate crossSystem).system;
    in
      nameValuePair
      "cross-for-${system-name}"
      (import ./cross/default.nix (args // {inherit crossSystem;}));

    systemsToCheck = with systems.examples; [
      # Maybe one day...
      #mingwW64

      # IFC1410
      ppc64

      powernv

      # D-TACQ
      { system = "armv7a-linux"; }

      raspberryPi
    ];
  in listToAttrs (map checkCrossFor systemsToCheck))
