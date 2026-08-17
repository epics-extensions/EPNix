{
  lib,
  pkgs,
  ports,
  ...
}:
{
  services = {
    # Phoebus services

    phoebus-olog = {
      enable = true;
      settings = {
        "server.http.enable" = true;
        "server.http.port" = ports.olog.port;

        "authenticationProviders" = [ "inMemory" ];
      };
    };

    phoebus-save-and-restore = {
      enable = true;
      settings = {
        "server.port" = ports.save-restore.port;
        "auth.impl" = "demo";
      };
      openFirewall = true;
    };

    channel-finder = {
      enable = true;
      openFirewall = true;
      settings = {
        "server.http.port" = ports.channel-finder.port;
        "demo_auth.enabled" = true;
      };
    };

    recceiver = {
      enable = true;

      channelfinderapi.DEFAULT = {
        BaseURL = "http://localhost:${toString ports.channel-finder.port}/ChannelFinder";
        username = "admin";
        password = "adminPass";
      };

      settings = {
        recceiver = {
          bind = "0.0.0.0:5050";

          # When receiving metadata,
          # print it on the command-line (show),
          # and send it to ChannelFinder (cf).
          procs = [
            "show"
            "cf"
          ];
        };
        cf = {
          # PV metadata to send to ChannelFinder
          alias = "on";
          recordDesc = "on";
          recordType = "on";
          environment_vars = {
            EPICS_BASE = "EpicsBase";
            EPICS_VERSION = "EpicsVersion";
            PWD = "WorkingDirectory";
          };
        };
      };
    };

    # Phoebus dependencies

    elasticsearch = {
      enable = true;
      package = pkgs.elasticsearch7;
      extraJavaOptions = [ "-Xmx256m" ];
    };

    # Kafka specified in ./phoebus-alarm.nix
  };

  networking.firewall.allowedTCPPorts = [
    ports.olog.port
  ];

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "elasticsearch"
    ];
}
