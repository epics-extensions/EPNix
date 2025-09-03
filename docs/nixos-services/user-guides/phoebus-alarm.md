# Phoebus Alarm single server setup

The Phoebus Alarm collection of services enables monitoring EPICS PVs,
and report alarms in a server.
Phoebus clients can then contact this server,
to see a list of current alarms, earlier alarms, and so on.

This guide focuses on installing and configuring these services on a single server.

For more information about these services,
examine the official documentation:

- [Service Architecture]
- [Alarm Server]
- [the README of Alarm Server] for reference only, don’t follow this guide on NixOS
- [Alarm Logging Service]

The Phoebus Alarm Logging Service can also be called the Phoebus Alarm Logger.

:::{important}
Make sure to follow the NixOS {doc}`pre-requisites`.
:::

## Single server Phoebus Alarm setup

To configure Phoebus Alarm, Phoebus Alarm Logger, Apache Kafka, and ElasticSearch on a single server,
add this to your configuration,
while taking care of replacing the IP address
and Kafka’s `clusterId`:

```{code-block} nix
:caption: {file}`phoebus-alarm.nix`

{lib, pkgs, ...}: let
  # Replace this with your machine's external IP address
  # or DNS domain name
  ip = "192.168.1.42";
  kafkaListenSockAddr = "${ip}:9092";
  kafkaControllerListenSockAddr = "${ip}:9093";
in {
  # The Phoebus Alarm server also automatically enables the Phoebus Alarm Logger
  services.phoebus-alarm-server = {
    enable = true;
    openFirewall = true;
    settings."org.phoebus.applications.alarm/server" = kafkaListenSockAddr;
  };

  services.phoebus-alarm-logger.settings."bootstrap.servers" = kafkaListenSockAddr;

  # Phoebus alarm needs Kafka.
  # If not already enabled elsewhere in your configuration,
  # the code below shows a single-server Kafka setup:
  services.apache-kafka = {
    enable = true;
    # Replace with a randomly generated uuid. You can get one by running:
    # nix shell 'nixpkgs#apacheKafka' -c kafka-storage.sh random-uuid
    clusterId = "xxxxxxxxxxxxxxxxxxxxxx";
    formatLogDirs = true;
    settings = {
      listeners = [
        "PLAINTEXT://${kafkaListenSockAddr}"
        "CONTROLLER://${kafkaControllerListenSockAddr}"
      ];
      # Adapt depending on your security constraints
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

  systemd.services.apache-kafka.unitConfig.StateDirectory = "apache-kafka";

  # Open kafka to the outside world
  networking.firewall.allowedTCPPorts = [9092];

  # Phoebus alarm needs ElasticSearch.
  # If not already enabled elsewhere in your configuration,
  # Enable it with the code below:
  services.elasticsearch = {
    enable = true;
    package = pkgs.elasticsearch7;
  };

  # Elasticsearch, needed by Phoebus Alarm Logger, is not free software (SSPL | Elastic License).
  # To accept the license, add the code below:
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "elasticsearch"
    ];
}
```

From the Phoebus graphical client side,
add this configuration:

```{code-block} ini
:caption: {file}`phoebus-client-settings.ini`

# For the Phoebus Alarm Server:
# Replace the IP address with your server's IP address or DNS domain name
org.phoebus.applications.alarm/server=192.168.1.42:9092

# For the Phoebus Alarm Logger:
# Replace the IP address again
org.phoebus.applications.alarm.logging.ui/service_uri=http://192.168.1.42:8080
```

## Configuring topics

The Phoebus Alarm system uses "topics" as a way of grouping alarms.
These topics are the available roots of your alarm tree.
You need to synchronize the topic names between:

- Phoebus Alarm Server
- Phoebus Alarm Logger
- Phoebus graphical clients

Changing the topic names in the Phoebus Alarm Server NixOS modules automatically creates them.

:::{warning}
Currently, the Phoebus Alarm Server doesn’t support several topics.
:::

For example,
if you want to have the topic `Project`,
add this configuration to the server:

```{code-block} nix
:caption: {file}`phoebus-alarm.nix`

{config, lib, ...}: let
  topics = ["Project"];
in {
  services.phoebus-alarm-server = {
    # ...
    settings = {
      # ...
      "org.phoebus.applications.alarm/config_names" = topics;
    };
  };

  services.phoebus-alarm-logger.settings.alarm_topics = topics;
}
```

For the Phoebus graphical client,
add this configuration:

```{code-block} ini
:caption: {file}`phoebus-client-settings.ini`

# config_name is only used in the Phoebus graphical client
org.phoebus.applications.alarm/config_name = Project
org.phoebus.applications.alarm/config_names = Project
```

## Configuring the address list

The address list is configured by default
using the {nix:option}`environment.epics` module.
See the {doc}`epics-environment` guide for mode information.

## Configuring email support

To enable email support,
set the `org.phoebus.email/mailport` setting.
Here is a list of options you might want to set:

```{code-block} nix
:caption: {file}`phoebus-alarm.nix`

{
  services.phoebus-alarm-server = {
    # ...
    settings = {
      # ...

      "org.phoebus.email/mailhost" = "smtp.my-company.org";

      # Optional:

      # 25 for plain SMTP
      "org.phoebus.email/mailport" = 25;
      # If authentication is needed:
      "org.phoebus.email/username" = "user";
      "org.phoebus.email/password" = "password";
      # Default address to be used for From:
      # if unspecified, then the last used "from" address is used
      "org.phoebus.email/from" = "Sender <the.sender@my-company.org>";
    };
  };
}
```

:::{warning}
Currently, Phoebus Alarm Server only supports plain SMTP.
:::

[alarm logging service]: https://control-system-studio.readthedocs.io/en/latest/services/alarm-logger/doc/index.html
[alarm server]: https://control-system-studio.readthedocs.io/en/latest/services/alarm-server/doc/index.html
[service architecture]: https://control-system-studio.readthedocs.io/en/latest/services_architecture.html
[the readme of alarm server]: https://github.com/ControlSystemStudio/phoebus/blob/master/app/alarm/Readme.md
