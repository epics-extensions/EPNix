{
  config,
  epnixLib,
  lib,
  pkgs,
  ...
} @ moduleAttrs: let
  cfg = config.services.phoebus-alarm-server;
  settingsFormat = pkgs.formats.javaProperties {};
  configFile = settingsFormat.generate "phoebus-alarm-server.properties" cfg.settings;

  localKafka = lib.hasPrefix "localhost:" cfg.settings."org.phoebus.applications.alarm/server";
in {
  options.services.phoebus-alarm-server = {
    enable = lib.mkEnableOption ''
      the Phoebus Alarm server

      By default this option will also enable the phoebus-alarm-logger service.
      Set `services.phoebus-alarm-logger.enable = false;` to disable it.
    '';

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

        Includes services:

        - Apache Kafka (if configured locally)
        - Phoebus Alarm Logger (if not disabled)

        Warning: this opens the firewall on all network interfaces.
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
      default = {};
      type = lib.types.submodule {
        freeformType = settingsFormat.type;
        options = {
          "org.phoebus.pv.ca/addr_list" = lib.mkOption {
            description = "Channel Access address list";
            type = with lib.types; listOf str;
            default = [];
            apply = lib.concatStringsSep " ";
          };

          "org.phoebus.pv.ca/auto_addr_list" = lib.mkOption {
            description = "Derive the CA address list from the available network interfaces";
            type = lib.types.bool;
            default = true;
            apply = lib.boolToString;
          };

          "org.phoebus.applications.alarm/server" = lib.mkOption {
            description = "Kafka server host:port";
            type = lib.types.str;
            default = "localhost:${toString config.services.apache-kafka.port}";
            defaultText = lib.literalExpression ''"localhost:''${toString config.services.apache-kafka.port}"'';
          };

          "org.phoebus.applications.alarm/config_name" = lib.mkOption {
            description = ''
              Name of alarm tree root.

              Will be used as the name for the Kafka topic.
            '';
            type = lib.types.str;
            # TODO: bug? From the code it seems that specifying multiple topics
            # here with create_topics will have issues (AlarmServerMain.java:654)
            default = "Accelerator";
          };

          "org.phoebus.applications.alarm/config_names" = lib.mkOption {
            description = ''
              Names of selectable alarm configurations.

              Will be used as the name for the Kafka topic.
            '';
            type = with lib.types; listOf str;
            # TODO: bug? From the code it seems that specifying multiple topics
            # here with create_topics will have issues (AlarmServerMain.java:654)
            default = [cfg.settings."org.phoebus.applications.alarm/config_name"];
            defaultText = lib.literalExpression ''[cfg.settings."org.phoebus.applications.alarm/config_name"]'';
            apply = lib.concatStringsSep ",";
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.phoebus-alarm-server = {
      description = "Phoebus Alarm Server";

      wantedBy = ["multi-user.target"];
      after = lib.mkIf localKafka ["apache-kafka.service"];

      environment.JAVA_OPTS = "-Dphoebus.user=/var/lib/phoebus-alarm-server";

      serviceConfig = {
        ExecStart = let
          args =
            [
              "-noshell"
              "-settings ${configFile}"
            ]
            ++ (lib.optional cfg.createTopics "-create_topics");
        in "${pkgs.epnix.phoebus-alarm-server}/bin/phoebus-alarm-server ${lib.concatStringsSep " " args}";
        DynamicUser = true;
        StateDirectory = "phoebus-alarm-server";
        # TODO: systemd hardening
      };
    };

    services.phoebus-alarm-logger = {
      enable = lib.mkDefault true;
      openFirewall = lib.mkIf cfg.openFirewall (lib.mkDefault true);
    };

    services.apache-kafka = lib.mkIf localKafka {
      enable = true;
      localSetup.enable = true;
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [
      config.services.apache-kafka.port
    ];
  };

  meta = {
    maintainers = with epnixLib.maintainers; [minijackson];
    # TODO:
    # doc = ./alarm-server.md;
  };
}
