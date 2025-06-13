# This tests both the phoebus-alarm-server, and phoebus-alarm-logger services
{epnixLib, ...}: {
  name = "phoebus-alarm-server-simple-check";
  meta.maintainers = with epnixLib.maintainers; [minijackson];

  nodes = {
    client = {pkgs, ...}: {
      environment = {
        epics.ca_addr_list = ["ioc"];
        systemPackages = [pkgs.kcat pkgs.epnix.epics-base];
      };
    };

    ioc = {pkgs, ...}: {
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
      lib,
      pkgs,
      ...
    }: let
      serverAddr = "192.168.1.3";
      kafkaListenSockAddr = "${serverAddr}:9092";
      kafkaControllerListenSockAddr = "${serverAddr}:9093";
    in {
      services.phoebus-alarm-server = {
        enable = true;
        openFirewall = true;
        settings."org.phoebus.applications.alarm/server" = kafkaListenSockAddr;
      };

      environment.epics = {
        ca_addr_list = ["ioc"];
        ca_auto_addr_list = false;
      };

      services.phoebus-alarm-logger.settings = {
        "bootstrap.servers" = kafkaListenSockAddr;
        "server.port" = 8082;
      };

      services.apache-kafka = {
        enable = true;
        clusterId = "Wwbk0wwKTueL2hJD0IGGdQ";
        formatLogDirs = true;
        settings = {
          listeners = [
            "PLAINTEXT://${kafkaListenSockAddr}"
            "CONTROLLER://${kafkaControllerListenSockAddr}"
          ];
          "listener.security.protocol.map" = [
            "PLAINTEXT:PLAINTEXT"
            "CONTROLLER:PLAINTEXT"
          ];
          "controller.quorum.voters" = [
            "1@${kafkaControllerListenSockAddr}"
          ];
          "controller.listener.names" = ["CONTROLLER"];

          "node.id" = 1;
          "process.roles" = ["broker" "controller"];

          "log.dirs" = ["/var/lib/apache-kafka"];
          "offsets.topic.replication.factor" = 1;
          "transaction.state.log.replication.factor" = 1;
          "transaction.state.log.min.isr" = 1;
        };
      };

      systemd.services.apache-kafka.unitConfig.StateDirectory = ["apache-kafka"];

      networking.firewall.allowedTCPPorts = [9092];

      services.elasticsearch = {
        enable = true;
        package = pkgs.elasticsearch7;
        extraConf = ''
          xpack.security.enabled: false
        '';
      };

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
