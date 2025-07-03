{
  config,
  epnixLib,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.phoebus-alarm-server;
  settingsFormat = pkgs.formats.javaProperties { };
  configFile = settingsFormat.generate "phoebus-alarm-server.properties" cfg.settings;
  configLocation = "phoebus/alarm-server.properties";
in
{
  options.services.phoebus-alarm-server = {
    enable = lib.mkEnableOption ''
      the Phoebus Alarm server

      By default this option will also enable the phoebus-alarm-logger service.
      Set {nix:option}`services.phoebus-alarm-logger.enable` to `false` to disable it'';

    # TODO: why undocumented? Seems useful
    createTopics = lib.mkOption {
      description = "Automatically create missing Kafka topics";
      type = lib.types.bool;
      default = true;
    };

    openFirewall = lib.mkOption {
      description = ''
        Open the firewall for all Phoebus Alarm related services.

        This uses the port numbers configured in each related NixOS module.

        Included services:

        - Phoebus Alarm Logger (if not disabled)

        :::{warning}
        This opens the firewall on all network interfaces.
        :::
      '';
      type = lib.types.bool;
      default = false;
    };

    settings = lib.mkOption {
      description = ''
        Configuration for the Phoebus Alarm Server.

        These options will be put into a `.properties` file.

        Note that options containing a "." must be quoted.
      '';
      default = { };
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

          "org.phoebus.applications.alarm/server" = lib.mkOption {
            description = "Kafka server host:port";
            type = lib.types.str;
          };

          # Waiting for: https://github.com/ControlSystemStudio/phoebus/issues/2843
          #
          #"org.phoebus.applications.alarm/config_name" = lib.mkOption {
          #  description = ''
          #    Name of alarm tree root.
          #    Will be used as the name for the Kafka topic.
          #  '';
          #  type = lib.types.str;
          #  # TODO: bug? From the code it seems that specifying multiple topics
          #  # here with create_topics will have issues (AlarmServerMain.java:654)
          #  default = "Accelerator";
          #};

          "org.phoebus.applications.alarm/config_names" = lib.mkOption {
            description = ''
              Names of selectable alarm configurations.

              Will be used as the name for the Kafka topic.
            '';
            type = with lib.types; listOf str;
            # TODO: bug? From the code it seems that specifying multiple topics
            # here with create_topics will have issues (AlarmServerMain.java:654)
            default = [ "Accelerator" ];
            apply = lib.concatStringsSep ",";
          };

          # Email options:
          # ---

          "org.phoebus.email/mailhost" = lib.mkOption {
            description = ''
              The SMTP server host.

              If set to `"DISABLE"` (the default), email support is disabled.
            '';
            type = lib.types.str;
            default = "DISABLE";
          };

          "org.phoebus.email/mailport" = lib.mkOption {
            description = ''
              The SMTP server port.
            '';
            type = lib.types.port;
            default = 25;
            apply = toString;
          };

          "org.phoebus.email/username" = lib.mkOption {
            description = ''
              Username for authenticating to the SMTP server.
            '';
            type = lib.types.str;
            default = "";
          };

          "org.phoebus.email/password" = lib.mkOption {
            description = ''
              Password for authenticating to the SMTP server.

              :::{note}
              The password will be put in plaintext,
              in the world-readable `/nix/store`.
              :::
            '';
            type = lib.types.str;
            default = "";
          };

          "org.phoebus.email/from" = lib.mkOption {
            description = ''
              Default address to be used for the email field {mailheader}`From`.

              If left empty, then the last used from address is used.
            '';
            type = lib.types.str;
            default = "";
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !(lib.hasInfix "," cfg.settings."org.phoebus.applications.alarm/config_names");
        message = "Phoebus Alarm Server doesn't support multiple topics, yet";
      }
    ];

    services.phoebus-alarm-server.settings = {
      "org.phoebus.pv.ca/addr_list" =
        if config.environment.epics.enable then config.environment.epics.ca_addr_list else [ ];
      "org.phoebus.pv.ca/auto_addr_list" =
        if config.environment.epics.enable then config.environment.epics.ca_auto_addr_list else true;
    };

    environment = {
      etc."${configLocation}".source = configFile;
      # Useful for importing alarm sets
      systemPackages = [ pkgs.epnix.phoebus-alarm-server ];
    };

    systemd.services.phoebus-alarm-server = {
      description = "Phoebus Alarm Server";

      wantedBy = [ "multi-user.target" ];

      environment.JAVA_OPTS = "-Dphoebus.user=/var/lib/phoebus-alarm-server";

      serviceConfig = {
        ExecStart =
          let
            args = [
              "-noshell"
              "-settings /etc/${configLocation}"
            ] ++ (lib.optional cfg.createTopics "-create_topics");
          in
          "${lib.getExe pkgs.epnix.phoebus-alarm-server} ${lib.concatStringsSep " " args}";
        DynamicUser = true;
        StateDirectory = "phoebus-alarm-server";
        # TODO: systemd hardening
      };
    };

    services.phoebus-alarm-logger = {
      enable = lib.mkDefault true;
      openFirewall = lib.mkIf cfg.openFirewall (lib.mkDefault true);
    };
  };

  meta.maintainers = with epnixLib.maintainers; [ minijackson ];
}
