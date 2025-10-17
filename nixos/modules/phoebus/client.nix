{
  config,
  lib,
  options,
  pkgs,
  ...
}:
let
  cfg = config.programs.phoebus-client;

  settingsFormat = pkgs.formats.javaProperties { };
  generatedSettings = settingsFormat.generate "phoebus-settings.ini" cfg.settings;

  defFilesFormat = pkgs.formats.keyValue { };
  toMacrosXML =
    macros:
    lib.concatStrings (
      lib.mapAttrsToList (
        name: value:
        let
          name' = lib.escapeXML name;
          value' = lib.escapeXML value;
        in
        "<${name'}>${value'}</${name'}>"
      ) macros
    );

  # Check if some options are set by the user
  colorDefIsUnset = cfg.colorDef == null;
  fontDefIsUnset = cfg.fontDef == null;
  settingsIsUnset = lib.length options.programs.phoebus-client.settings.definitions == 1;
  settingsFileIsSet = cfg.settingsFile != generatedSettings;

  # If the user sets the settingsFile,
  # then these options must be unset,
  # because they'll end up being unused.
  warningCheck = settingsFileIsSet -> colorDefIsUnset && fontDefIsUnset && settingsIsUnset;
in
{
  options.programs.phoebus-client = {
    enable = lib.mkEnableOption "installing and configuring the Phoebus client";

    package = lib.mkPackageOption pkgs "Phoebus" {
      default = [
        "epnix"
        "phoebus"
      ];
      extraDescription = ''
        This package is "wrapped" into {nix:option}`finalPackage`
        to use the given preference settings,
        Java options,
        etc.
      '';
    };

    finalPackage = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      default = cfg.package.override {
        inherit (cfg) settingsFile java_opts;
      };
      defaultText = lib.literalMD "The wrapped Phoebus package";
      description = ''
        The final package that will be used in the system,
        a Phoebus package that will use the provided preference settings,
        Java options,
        etc.

        The original package is taken from {nix:option}`package`.
      '';
    };

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

    fontDef = lib.mkOption {
      description = ''
        Phoebus font definitions.

        If unset,
        use the fonts from Phoebus' [{file}`examples/font.def`].

        If set,
        expand on the default fonts from Phoebus.

        :::{warning}
        If {nix:option}`fontDef` is set,
        the example fonts from [{file}`examples/font.def`],
        such as `Oddball`,
        won't be provided by default.
        :::

          [{file}`examples/font.def`]: https://github.com/ControlSystemStudio/phoebus/blob/v${pkgs.epnix.phoebus.version}/app/display/model/src/main/resources/examples/font.def

        :Name format:
          ```
          NamedFont
          NamedFont(OS)
          ```
        :Font format:
          ```
          Family - Style - Size
          @PreviouslyDefinedNamedFont
          ```
        :Style: `regular`, `bold`, `italic`, or `bold italic`.
        :Size: Font height in pixels
        :Family: Font family name,
          such as `Liberation Sans`, `Liberation Mono`, or `Liberation Serif`;
        :OS: `windows`, `linux`, or `macosx`.
      '';
      type = with lib.types; nullOr (attrsOf str);
      default = null;
      example = {
        Oddball = "Comic Sans MS-regular-40";
        "Oddball(linux)" = "PakTypeNaqsh-regular-40";
        "Oddball(macosx)" = "Herculanum-regular-40";
      };
    };

    settings = lib.mkOption {
      description = ''
        Phoebus preference setting,
        as defined in the [Preferences Listing] Phoebus documentation.

          [Preferences Listing]: https://control-system-studio.readthedocs.io/en/latest/preference_properties.html
      '';
      default = { };
      example = {
        "org.phoebus.applications.alarm/server" = "localhost:9092";
        "org.phoebus.applications.alarm/config_names" = "Accelerator, Demo";
        "org.csstudio.trends.databrowser3/urls" = "pbraw://localhost:8080/retrieval";
      };
      type = lib.types.submodule {
        freeformType = settingsFormat.type;
        options = {
          "org.phoebus.pv.ca/addr_list" = lib.mkOption {
            description = ''
              Channel Access address list.

              Use `lib.mkForce` to override values from {nix:option}`environment.epics.ca_addr_list`.
            '';
            type = with lib.types; listOf str;
            defaultText = lib.literalExpression ''
              if config.environment.epics.enable
              then config.environment.epics.ca_addr_list
              else [];
            '';
            apply = lib.concatStringsSep " ";
          };

          "org.phoebus.pv.ca/auto_addr_list" = lib.mkOption {
            description = ''
              Derive the CA address list from the available network interfaces.

              Use `lib.mkForce` to override values from {nix:option}`environment.epics.ca_auto_addr_list`.
            '';
            type = lib.types.bool;
            defaultText = lib.literalExpression ''
              if config.environment.epics.enable
              then config.environment.epics.ca_auto_addr_list
              else [];
            '';
            apply = lib.boolToString;
          };

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
              if cfg.colorDef != null then
                defFilesFormat.generate "phoebus-color.def" cfg.colorDef
              else
                "examples:color.def";
            defaultText = "<file generated from 'colorDef' if defined, else the default colors>";
            example = lib.literalExpression "./color.def";
          };

          "org.csstudio.display.builder.model/font_files" = lib.mkOption {
            description = ''
              Named fonts definition files.

              One or more {file}`{font}.def` files, separated by `;`.

              By default,
              the file is generated from the {nix:option}`fontDef` option,
              if defined,
              or to built-in copy of [{file}`examples/font.def`]
              if {nix:option}`fontDef` isn't defined.

              :::{note}
              Use the this option
              if you want to import an already existing {file}`font.def` file.
              If you override this option, {nix:option}`fontDef` options are ignored.
              :::
            '';
            type = with lib.types; either path str;
            default =
              if cfg.fontDef != null then
                defFilesFormat.generate "phoebus-font.def" cfg.fontDef
              else
                "examples:font.def";
            defaultText = "<file generated from 'fontDef' if defined, else the default fonts>";
            example = lib.literalExpression "./font.def";
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
            default = { };
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
      default = generatedSettings;
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
    warnings = lib.mkIf (!warningCheck) [
      "`programs.phoebus-client.settingsFile` was set, and at least one of the `settings`, `colorDef`, or `fontDef` options are set, but they will be ignored."
    ];

    programs.phoebus-client.settings = {
      "org.phoebus.pv.ca/addr_list" =
        if config.environment.epics.enable then config.environment.epics.ca_addr_list else [ ];
      "org.phoebus.pv.ca/auto_addr_list" =
        if config.environment.epics.enable then config.environment.epics.ca_auto_addr_list else true;
    };
    environment.systemPackages = [ cfg.finalPackage ];
  };
}
