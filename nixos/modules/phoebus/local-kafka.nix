{
  config,
  lib,
  ...
}: {
  # This is put as a separate file, so that both the phoebus-alarm-server and
  # phoebus-alarm-service provide the same configuration, if used separately
  options.services.apache-kafka.localSetup.enable = lib.mkEnableOption "Configure a local, non-replicated Kafka instance";

  config = lib.mkIf config.services.apache-kafka.localSetup.enable {
    # TODO: document replication setup
    services.apache-kafka = {
      logDirs = lib.mkDefault ["/var/lib/apache-kafka"];
      extraProperties = lib.mkDefault ''
        offsets.topic.replication.factor=1
        transaction.state.log.replication.factor=1
        transaction.state.log.min.isr=1
      '';
    };

    systemd.services.apache-kafka = {
      after = ["zookeeper.service"];
      unitConfig.StateDirectory = lib.mkDefault "apache-kafka";
    };

    services.zookeeper.enable = lib.mkDefault true;
  };
}
