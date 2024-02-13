# This tests both the phoebus-alarm-server, and phoebus-alarm-logger services
{
  epnixLib,
  lib,
  pkgs,
  ...
}: {
  name = "phoebus-alarm-server-simple-check";
  meta.maintainers = with epnixLib.maintainers; [minijackson];

  nodes = {
    client = {
      environment = {
        sessionVariables.EPICS_CA_ADDR_LIST = ["ioc"];
        systemPackages = [pkgs.kcat pkgs.epnix.epics-base];
      };
    };

    ioc = {
      systemd.services.ioc = {
        description = "Test IOC to be monitored with the Phoebus Alarm server";
        serviceConfig.ExecStart = "${pkgs.epnix.epics-base}/bin/softIoc -S -d ${./ioc.db}";
        wantedBy = ["multi-user.target"];
        after = ["network.target"];
      };

      networking.firewall = {
        allowedTCPPorts = [5064];
        allowedUDPPorts = [5064];
      };
    };

    server = {
      config,
      pkgs,
      ...
    }: let
      kafkaPort = toString config.services.apache-kafka.port;
      serverAddr = "192.168.1.3";
      kafkaListenSockAddr = "${serverAddr}:${kafkaPort}";
    in {
      services.phoebus-alarm-server = {
        enable = true;
        openFirewall = true;
        settings = {
          "org.phoebus.pv.ca/addr_list" = ["ioc"];
          "org.phoebus.pv.ca/auto_addr_list" = false;
          "org.phoebus.applications.alarm/server" = kafkaListenSockAddr;
        };
      };

      services.phoebus-alarm-logger.settings."bootstrap.servers" = kafkaListenSockAddr;

      services.elasticsearch = {
        enable = true;
        package = pkgs.elasticsearch7;
      };

      # Single-server Kafka setup
      services.apache-kafka = {
        enable = true;
        logDirs = ["/var/lib/apache-kafka"];
        # Tell Apache Kafka to listen on this IP address
        # If you don't have a DNS domain name, it's best to set a specific, non-local IP address.
        extraProperties = ''
          listeners=PLAINTEXT://${kafkaListenSockAddr}
          offsets.topic.replication.factor=1
          transaction.state.log.replication.factor=1
          transaction.state.log.min.isr=1
        '';
      };

      systemd.services.apache-kafka = {
        after = ["zookeeper.service"];
        unitConfig.StateDirectory = "apache-kafka";
      };

      services.zookeeper = {
        enable = true;
        extraConf = ''
          # Port conflicts by default with phoebus-alarm-logger's port
          admin.enableServer=false
        '';
      };

      # Open kafka to the outside world
      networking.firewall.allowedTCPPorts = [
        config.services.apache-kafka.port
      ];

      nixpkgs.config.allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [
          # Elasticsearch can be used as an SSPL-licensed software, which is
          # not open-source. But as we're using it run tests, not exposing
          # any service, this should be fine.
          "elasticsearch"
        ];

      virtualisation.memorySize = 3072;
    };
  };

  testScript = builtins.readFile ./alarm.py;
}
