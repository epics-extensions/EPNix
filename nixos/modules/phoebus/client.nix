{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.phoebus-client;
  pkg = pkgs.epnix.phoebus.override {java_opts = cfg.java_opts;};
in {
  options.programs.phoebus-client = {
    enable = lib.mkEnableOption "installing and configuring the Phoebus client";
    java_opts = lib.mkOption {
      type = lib.types.str;
      default = "-XX:MinHeapSize=128m -XX:MaxHeapSize=4g -XX:InitialHeapSize=1g -XX:MaxHeapFreeRatio=10 -XX:MinHeapFreeRatio=5 -XX:-ShrinkHeapInSteps -XX:NativeMemoryTracking=detail";
      example = "-XX:MinHeapSize=128m -XX:MaxHeapSize=4g -XX:InitialHeapSize=1g";
      description = ''
        Set Java options for the Phoebus client.

        For more information, see:
        https://docs.oracle.com/en/java/javase/21/docs/specs/man/java.html#extra-options-for-java
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [pkg];
  };
}
