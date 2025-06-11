{
  lib,
  epnixLib,
  pkgs,
  ...
}: let
  ioc = pkgs.epnix.support.callPackage ./ioc.nix {};
in {
  name = "channel-finder-simple-check";
  meta.maintainers = with epnixLib.maintainers; [minijackson];

  nodes = let
    serverPort = 5050;
    announcerPort = 5049;
  in {
    server = {pkgs, ...}: {
      environment.systemPackages = [pkgs.epnix.epics-base];

      services.recceiver = {
        enable = lib.mkDefault true;

        channelfinderapi.DEFAULT = {
          BaseURL = "http://localhost:8082/ChannelFinder";
          username = "admin";
          password = "adminPass";
        };

        settings = {
          recceiver = {
            loglevel = "DEBUG";
            bind = "0.0.0.0:${toString serverPort}";
            addrlist = ["192.168.1.255:${toString announcerPort}"];
            procs = ["show" "cf"];
          };
          cf = {
            alias = "on";
            recordDesc = "on";
            recordType = "on";
            environment_vars = {
              ENGINEER = "Engineer";
              EPICS_BASE = "EpicsBase";
              EPICS_VERSION = "EpicsVersion";
              PWD = "WorkingDirectory";
            };
          };
        };
      };

      networking.firewall.allowedTCPPorts = [serverPort];

      services.channel-finder = {
        enable = true;
        openFirewall = true;
        settings = {
          "demo_auth.enabled" = true;
          "server.port" = 8444;
          "server.http.port" = 8082;
        };
      };

      services.elasticsearch = {
        enable = true;
        package = pkgs.elasticsearch7;
      };

      nixpkgs.config.allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [
          # Elasticsearch can be used as an SSPL-licensed software, which is
          # not open-source. But as we're using it run tests, not exposing
          # any service, this should be fine.
          "elasticsearch"
        ];

      # Else some applications might get killed by the OOM killer
      virtualisation.memorySize = 2047;
    };

    client = {
      environment.systemPackages = [pkgs.epnix.epics-base];
      services.iocs.ioc = {
        package = ioc;
        workingDirectory = "iocBoot/iocSimple";
      };
      networking.firewall.allowedUDPPorts = [announcerPort];
    };
  };

  extraPythonPackages = p: [p.json5];
  # Type checking on extra packages doesn't work yet
  skipTypeCheck = true;

  testScript = builtins.readFile ./test_script.py;
}
