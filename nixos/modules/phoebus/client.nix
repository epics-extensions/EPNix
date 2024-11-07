{
  config,
  lib,
  epnix,
  pkgs,
  ...
}: let
  cfg = config.programs.phoebus-client;
  pkg = pkgs.epnix.phoebus.override {java_opts = cfg.java_opts;};
in {
  options.programs.phoebus-client = {
    enable = lib.mkEnableOption ''Enable the Phoebus client'';
    java_opts = lib.mkOption {
      type = lib.types.str;
      default = "-XX:MinHeapSize=128m -XX:MaxHeapSize=4g -XX:InitialHeapSize=1g -XX:MaxHeapFreeRatio=10 -XX:MinHeapFreeRatio=5 -XX:-ShrinkHeapInSteps -XX:NativeMemoryTracking=detail";
      example = "-XX:MinHeapSize=128m -XX:MaxHeapSize=4g -XX:InitialHeapSize=1g";
      description = ''
        This wrapper for the `phoebus-unwrapped` executable sets the `JAVA_OPTS`
        environment variable with the provided `java_opts` value.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [pkg];
  };
}
