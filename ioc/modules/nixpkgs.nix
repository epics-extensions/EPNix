{lib, ...}: {
  options.nixpkgs = {
    overlays = lib.mkOption {
      default = [];
      type = with lib.types; listOf unspecified;
      description = "Nixpkgs overlays to override the default packages used";
    };
  };
}
