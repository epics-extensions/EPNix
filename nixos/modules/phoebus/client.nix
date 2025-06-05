{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.phoebus-client;
  settingsFormat = pkgs.formats.javaProperties {};
  pkg = pkgs.epnix.phoebus.override {
    inherit (cfg) settingsFile java_opts;
  };
in {
  options.programs.phoebus-client = {
    enable = lib.mkEnableOption "installing and configuring the Phoebus client";

    settings = lib.mkOption {
      description = ''
        Phoebus preference setting,
        as defined in the [Preferences Listing] Phoebus documentation.

          [Preferences Listing]: https://control-system-studio.readthedocs.io/en/latest/preference_properties.html
      '';
      default = {};
      example = {
        "org.phoebus.applications.alarm/server" = "localhost:9092";
        "org.phoebus.applications.alarm/config_names" = "Accelerator, Demo";
        "org.csstudio.trends.databrowser3/urls" = "pbraw://localhost:8080/retrieval";
      };
      type = lib.types.submodule {
        freeformType = settingsFormat.type;
        options = {
        };
      };
    };

    settingsFile = lib.mkOption {
      description = ''
        Path to a {file}`settings.ini` file, to be used by Phoebus.

        By default,
        the file is generated from the {nix:option}`settings` option.

        :::{note}
        Use the {nix:option}`settingsFile` option
        if you want to import an already existing {file}`settings.ini` file.
        If you override this option, {nix:option}`settings` options are ignored.
        :::

        May also point to a remote URL.
      '';
      type = with lib.types; either path str;
      default = settingsFormat.generate "phoebus-settings.ini" cfg.settings;
      defaultText = "<file generated from the 'settings' options>";
      example = lib.literalExpression "./settings.ini";
    };

    java_opts = lib.mkOption {
      type = lib.types.str;
      default = "-XX:MinHeapSize=128m -XX:MaxHeapSize=4g -XX:InitialHeapSize=1g -XX:MaxHeapFreeRatio=10 -XX:MinHeapFreeRatio=5 -XX:-ShrinkHeapInSteps -XX:NativeMemoryTracking=detail";
      example = "-XX:MinHeapSize=128m -XX:MaxHeapSize=4g -XX:InitialHeapSize=1g";
      description = ''
        Set Java options for the Phoebus client.

        For more information, see:
        <https://docs.oracle.com/en/java/javase/21/docs/specs/man/java.html#extra-options-for-java>
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [pkg];
  };
}
