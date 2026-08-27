{ lib, epnixLib }:
let
  finalSystem = epnixLib.inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      epnixLib.inputs.self.nixosModules.default
      epnixLib.inputs.self.nixosModules.phoebus-ecosystem
    ];
  };

  image = finalSystem.config.system.build.images.virtualbox;
in
image
// {
  meta = image.meta or { } // {
    description = "Phoebus ecosystem VirtualBox OVA";
    license = lib.licenses.asl20;
    maintainers = with epnixLib.maintainers; [ minijackson ];
  };
}
