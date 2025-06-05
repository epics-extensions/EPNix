{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.phoebus-client;

  settingsFormat = pkgs.formats.javaProperties {};
  defFilesFormat = pkgs.formats.keyValue {};
  toMacrosXML = macros:
    lib.concatStrings (
      lib.mapAttrsToList
      (name: value: let
        name' = lib.escapeXML name;
        value' = lib.escapeXML value;
      in "<${name'}>${value'}</${name'}>")
      macros
    );

  pkg = pkgs.epnix.phoebus.override {
    inherit (cfg) settingsFile java_opts;
  };
in {
  options.programs.phoebus-client = {
    enable = lib.mkEnableOption "installing and configuring the Phoebus client";

    colorDef = lib.mkOption {
      description = ''
        Phoebus color definitions.

        If unset,
        use the colors from Phoebus' [{file}`examples/color.def`].

        If set,
        expand on the default colors from Phoebus.

        :::{warning}
        If {nix:option}`colorDef` is set,
        the "additional colors" from [{file}`examples/color.def`],
        such as `Header_Background`, `On`, or `Off`,
        won't be provided by default.
        :::

          [{file}`examples/color.def`]: https://github.com/ControlSystemStudio/phoebus/blob/v${pkgs.epnix.phoebus.version}/app/display/model/src/main/resources/examples/color.def

        :Color format:
          ```
          red, green, blue
          red, green, blue, alpha
          PreviouslyDefinedNameOfColor
          ```

          with values in 0-255 range.

        Whenever possible, use named colors in displays
        instead of arbitrary red/green/blue values.
      '';
      type = with lib.types; nullOr (attrsOf str);
      default = null;
      example = {
        OK = "0, 255, 0";
        On = "OK";
        Transparent = "255, 255, 255, 0";
      };
    };

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
          "org.csstudio.display.builder.model/color_files" = lib.mkOption {
            description = ''
              Named colors definition files.

              One or more {file}`{color}.def` files, separated by `;`.

              By default,
              the file is generated from the {nix:option}`colorDef` option,
              if defined,
              or to built-in copy of [{file}`examples/color.def`]
              if {nix:option}`colorDef` isn't defined.

              :::{note}
              Use the this option
              if you want to import an already existing {file}`color.def` file.
              If you override this option, {nix:option}`colorDef` options are ignored.
              :::
            '';
            type = with lib.types; either path str;
            default =
              if cfg.colorDef != null
              then defFilesFormat.generate "phoebus-color.def" cfg.colorDef
              else "examples:color.def";
            defaultText = "<file generated from 'colorDef' if defined, else the default colors>";
            example = lib.literalExpression "./color.def";
          };

          "org.csstudio.display.builder.model/macros" = lib.mkOption {
            description = ''
              Global macros, used for all displays.

              Displays start with these macros,
              and can then add new macros or overwrite
              the values of these macros.

              :Format:
                The macro name must be a valid XML tag name:

                -   Must start with character
                -   May then contain characters or numbers
                -   May also contain underscores
            '';
            type = with lib.types; attrsOf str;
            apply = toMacrosXML;
            default = {};
            example = {
              EXAMPLE_MACRO = "Value from Preferences";
              TEST = "true";
            };
          };
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
