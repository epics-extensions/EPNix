{
  epnixLib,
  inputs,
  lib,
  ...
}:
lib.fix (self: {
  visibleOptionDocs = lib.filter (opt: opt.visible && !opt.internal && (lib.head opt.loc) != "_module");

  optionsContent = options: headingLevel:
    lib.concatStringsSep "\n"
    (map
      (epnixLib.documentation.markdown.fromOption headingLevel)
      (self.visibleOptionDocs options));

  iocOptions = iocConfig:
    lib.optionAttrSetToDocList
    (epnixLib.evalEpnixModules {
      nixpkgsConfig = {};
      epnixConfig = iocConfig;
    })
    .options;

  nixosOptions = nixosConfig: let
    allOptions =
      lib.optionAttrSetToDocList
      # Weirdly, the `nixoSystem` function is only available through the
      # nixpkgs flake's `lib` attrset.
      (inputs.nixpkgs.lib.nixosSystem {
        modules = [
          inputs.self.nixosModules.nixos
          nixosConfig
          {nixpkgs.hostPlatform = "x86_64-linux";}
        ];
      })
      .options;

    isEpnixOption = value:
      (value ? declarations)
      && lib.hasPrefix "${inputs.self}" (lib.head value.declarations);

    epnixNixosOptions = lib.filter isEpnixOption allOptions;
  in
    epnixNixosOptions;
})
