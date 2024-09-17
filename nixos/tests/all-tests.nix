{
  nixpkgs,
  pkgs,
  self,
  system,
}: let
  inherit (pkgs) lib;

  nixosTesting = import (nixpkgs + "/nixos/lib/testing-python.nix") {
    inherit pkgs system;
    extraConfigurations = [
      self.nixosModules.nixos
    ];
  };

  handleTest = path: args: nixosTesting.simpleTest (import path (pkgs // args));
in {
  archiver-appliance = handleTest ./archiver-appliance {};
  ca-gateway = handleTest ./ca-gateway.nix {};
  channel-finder = handleTest ./channel-finder {};
  phoebus-alarm = handleTest ./phoebus/alarm.nix {};
  phoebus-olog = handleTest ./phoebus/olog.nix {};
  phoebus-save-and-restore = handleTest ./phoebus/save-and-restore.nix {};
  phoebus-scan-server = handleTest ./phoebus/scan-server.nix {};
}
