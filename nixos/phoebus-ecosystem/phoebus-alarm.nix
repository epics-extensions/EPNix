{ config, ports, ... }:
let
  # This is the address clients will actually use to connect to Kafka,
  # it also needs to be configured in the Kafka server for some reason,
  # in "advertised.listeners".
  # It is both the "localhost" address when inside and outside the VM,
  # since the port is forwarded.
  kafkaAdvertisedListenSockAddr = "127.0.0.1:${toString ports.apache-kafka.port}";

  # This is an address internal to Kafka,
  # that Kafka uses to synchronise itself with itself??
  # Needed for a non-Zookeeper configuration
  kafkaControllerListenSockAddr = "127.0.0.1:9093";
in
{
  services = {
    phoebus-alarm-server = {
      enable = true;
      openFirewall = true;
      settings."org.phoebus.applications.alarm/server" = kafkaAdvertisedListenSockAddr;
    };

    phoebus-alarm-logger.settings = {
      "server.port" = ports.alarm-logger.port;
      "bootstrap.servers" = kafkaAdvertisedListenSockAddr;
    };

    apache-kafka = {
      enable = true;
      # Randomly generated uuid got by running:
      # nix shell 'nixpkgs#apacheKafka' -c kafka-storage.sh random-uuid
      clusterId = "8MEBIhkRS963am5l4DsQlQ";
      formatLogDirs = true;
      jvmOptions = [ "-Xmx256m" ];
      settings = {
        listeners = [
          # This is the address Kafka will listen to,
          # so it will listen to any interface
          "LISTENER://0.0.0.0:9092"
          "CONTROLLER://${kafkaControllerListenSockAddr}"
        ];
        "advertised.listeners" = [ "LISTENER://${kafkaAdvertisedListenSockAddr}" ];
        "inter.broker.listener.name" = "LISTENER";
        "listener.security.protocol.map" = [
          "LISTENER:PLAINTEXT"
          "CONTROLLER:PLAINTEXT"
        ];
        "controller.quorum.voters" = [
          "1@${kafkaControllerListenSockAddr}"
        ];
        "controller.listener.names" = [ "CONTROLLER" ];

        "node.id" = 1;
        "process.roles" = [
          "broker"
          "controller"
        ];

        "log.dirs" = [ "/var/lib/apache-kafka" ];
        "offsets.topic.replication.factor" = 1;
        "transaction.state.log.replication.factor" = 1;
        "transaction.state.log.min.isr" = 1;
      };
    };
  };

  systemd.services.apache-kafka.unitConfig.StateDirectory = "apache-kafka";

  networking.firewall.allowedTCPPorts = [ ports.apache-kafka.port ];

  environment.systemPackages = [ config.services.apache-kafka.package ];
}
