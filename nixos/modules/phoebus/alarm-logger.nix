{
  config,
  epnixLib,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.phoebus-alarm-logger;
  settingsFormat = pkgs.formats.javaProperties { };
  configFile = settingsFormat.generate "phoebus-alarm-logger.properties" cfg.settings;
in
{
  options.services.phoebus-alarm-logger = {
    enable = lib.mkEnableOption ''
      the Phoebus Alarm logger.

      The alarm logging service records all alarm messages to create an archive
      of all alarm state changes and the associated actions'';

    openFirewall = lib.mkOption {
      description = ''
        Open the firewall for the Phoebus Alarm Logger service.

        :::{warning}
        This opens the firewall on all network interfaces.
        :::
      '';
      type = lib.types.bool;
      default = false;
    };

    settings = lib.mkOption {
      description = ''
        Configuration for the Phoebus Alarm Logger.

        These options will be put into a `.properties` file.

        Note that options containing a "." must be quoted.

        Available options can be seen here:
        <https://github.com/ControlSystemStudio/phoebus/blob/v${pkgs.epnix.phoebus-alarm-logger.version}/services/alarm-logger/src/main/resources/application.properties>
      '';
      default = { };
      type = lib.types.submodule {
        freeformType = settingsFormat.type;
        options = {
          "server.port" = lib.mkOption {
            description = "Port for the Alarm Logger service";
            type = lib.types.port;
            default = 8080;
            apply = toString;
          };

          alarm_topics = lib.mkOption {
            description = "Alarm topics to be logged";
            type = with lib.types; listOf str;
            default = [ "Accelerator" ];
            apply = lib.concatStringsSep ",";
          };

          es_urls = lib.mkOption {
            description = ''
              List of Elasticsearch node URLs.

              All nodes must belong to the same cluster.
            '';
            type = with lib.types; listOf str;
            default = [ "http://localhost:${toString config.services.elasticsearch.port}" ];
            defaultText = lib.literalExpression ''[ "http://localhost:''${toString config.services.elasticsearch.port}" ]'';
            apply = lib.concatStringsSep ",";
          };

          es_sniff = lib.mkOption {
            description = "Use the Elasticseach sniff feature";
            type = lib.types.bool;
            default = false;
            apply = lib.boolToString;
          };

          es_create_templates = lib.mkOption {
            description = "Automatically create the index templates needed";
            type = lib.types.bool;
            default = true;
            apply = lib.boolToString;
          };

          "bootstrap.servers" = lib.mkOption {
            description = "Location of the Kafka server";
            type = lib.types.str;
          };

          date_span_units = lib.mkOption {
            description = ''
              Units of the indices date span.

              Can be Days (D), Weeks (W), Months (M), Years (Y).
            '';
            type = lib.types.enum [
              "D"
              "W"
              "M"
              "Y"
            ];
            default = "M";
          };

          thread_pool_size = lib.mkOption {
            description = ''
              Size of the thread pool for message and command loggers.

              Two threads per topic/configuration are required.
            '';
            type = lib.types.ints.positive;
            default = config.services.elasticsearch.port;
            defaultText = lib.literalExpression "config.services.elasticsearch.port";
            apply = toString;
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion =
          let
            topics = lib.splitString "," cfg.settings.alarm_topics;
            thread_pool_size = lib.toInt cfg.settings.thread_pool_size;
          in
          thread_pool_size >= (lib.length topics) * 2;
        message = "At least 2 threads per topic is required";
      }
    ];

    services.phoebus-alarm-logger.settings."logging.level.org.springframework.web.filter.CommonsRequestLoggingFilter" =
      "INFO";

    systemd.services.phoebus-alarm-logger = {
      description = "Phoebus Alarm Logger";

      wantedBy = [ "multi-user.target" ];

      environment = {
        # Weirdly not "phoebus.user"
        JAVA_OPTS = "-Djava.util.prefs.userRoot=/var/lib/phoebus-alarm-logger";

        # Our config file is both the config file for phoebus-alarm-logger,
        # and for SpringBoot.
        # The '-properties' command-line argument is only for phoebus-alarm-logger,
        # *not* SpringBoot.
        SPRING_CONFIG_IMPORT = configFile;
      };

      serviceConfig = {
        ExecStart =
          let
            args = [
              "-noshell"
              "-properties ${configFile}"
            ];
          in
          "${lib.getExe pkgs.epnix.phoebus-alarm-logger} ${lib.concatStringsSep " " args}";
        DynamicUser = true;
        StateDirectory = "phoebus-alarm-logger";
        # TODO: systemd hardening
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [
      (lib.toInt cfg.settings."server.port")
    ];
  };

  meta.maintainers = with epnixLib.maintainers; [ minijackson ];
}
