---
title: Phoebus Alarm single server setup
---

The Phoebus Alarm collection of services enables monitoring EPICS PVs,
and report alarms in a server.
Phoebus clients can then contact this server,
to see a list of current alarms, earlier alarms, and so on.

This guide focuses on installing and configuring these services on a single server.

For more information about these services,
examine the official documentation:

-   [Service Architecture]
-   [Alarm Server]
-   [the README of Alarm Server] for reference only, don't follow this guide on NixOS
-   [Alarm Logging Service]

The Phoebus Alarm Logging Service can also be called the Phoebus Alarm Logger.

  [Service Architecture]: https://control-system-studio.readthedocs.io/en/latest/services_architecture.html
  [Alarm Server]: https://control-system-studio.readthedocs.io/en/latest/services/alarm-server/doc/index.html
  [the README of Alarm Server]: https://github.com/ControlSystemStudio/phoebus/blob/master/app/alarm/Readme.md
  [Alarm Logging Service]: https://control-system-studio.readthedocs.io/en/latest/services/alarm-logger/doc/index.html

{{< include _pre-requisites.md >}}

# Single server Phoebus Alarm setup

To configure Phoebus Alarm, Phoebus Alarm Logger, Apache Kafka, and ElasticSearch on a single server,
add this to your configuration:

``` nix
{config, lib, ...}: let
  kafkaPort = toString config.services.apache-kafka.port;
  # Replace this with your machine's IP address
  # or DNS domain name
  ip = "192.168.1.42";
  kafkaListenSockAddr = "${ip}:${kafkaPort}";
in {
  # The Phoebus Alarm server also automatically enables the Phoebus Alarm Logger
  services.phoebus-alarm-server = {
    enable = true;
    openFirewall = true;
    settings."org.phoebus.applications.alarm/server" = kafkaListenSockAddr;
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

``` ini
# For the Phoebus Alarm Server:
# Replace the IP address with your server's IP address or DNS domain name
org.phoebus.applications.alarm/server=192.168.1.42:9092

# For the Phoebus Alarm Logger:
# Replace the IP address again
org.phoebus.applications.alarm.logging.ui/service_uri=http://192.168.1.42:8080
```

# Configuring topics

The Phoebus Alarm system uses "topics" as a way of grouping alarms.
These topics are the available roots of your alarm tree.
You need to synchronize the topic names between:

-   Phoebus Alarm Server
-   Phoebus Alarm Logger
-   Phoebus graphical clients

Changing the topic names in the Phoebus Alarm Server NixOS modules automatically creates them.

::: callout-warning
Currently, the Phoebus Alarm Server doesn't support several topics.
:::

For example,
if you want to have the topic `Project`,
add this configuration to the server:

``` nix
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

``` ini
# config_name is only used in the Phoebus graphical client
org.phoebus.applications.alarm/config_name = Project
org.phoebus.applications.alarm/config_names = Project
```

# Configuring the address list

If you want to limit the IOCs reachable by the Phoebus Alarm Server,
use these option:

``` nix
{
  services.phoebus-alarm-server = {
    # ...
    settings = {
      # ...

      # The Phoebus Alarm Server will only have access to these IOCs
      "org.phoebus.pv.ca/addr_list" = ["192.168.1.5" "192.168.1.42"];
      "org.phoebus.pv.ca/auto_addr_list" = false;
    };
  };
}
```

# Configuring email support

To enable email support,
set the `org.phoebus.email/mailport` setting.
Here is a list of options you might want to set:

``` nix
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

::: callout-warning
Currently, Phoebus Alarm Server only supports plain SMTP.
:::

