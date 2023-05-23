{
  config,
  epnix,
  lib,
  pkgs,
  ...
}: let
  globalConfig = config;

  iocTop = "${config.epnix.outputs.build}";
in {
  options.epnix.nixos = {
    services = lib.mkOption {
      description = ''
        Services for which to create a systemd service config.
      '';
      example = {
        ioc = {
          app = "examples";
          ioc = "iocExamples";
        };
      };
      type = lib.types.attrsOf (lib.types.submodule ({config, ...}: {
        options = {
          app = lib.mkOption {
            type = lib.types.str;
            example = "my_exec";
            description = ''
              Name of the app to start the IOC with.
            '';
          };

          ioc = lib.mkOption {
            type = lib.types.str;
            example = "iocMyDevice";
            description = ''
              Name of the directory under `iocBoot` containing the start commands.
            '';
          };

          startCommandsFile = lib.mkOption {
            default = "st.cmd";
            example = "other_st.cmd";
            type = lib.types.str;
            description = ''
              Name of the file containing the EPICS start commands.
            '';
          };

          config = lib.mkOption {
            type = lib.types.attrs;
            readOnly = true;
            description = ''
              Resulting configuration for the systemd service.
            '';
          };

          procServ = {
            port = lib.mkOption {
              default = 2000;
              type = lib.types.port;
              description = ''
                Port where the procServ utility will listen.
              '';
            };

            options = lib.mkOption {
              default = {};
              example = {
                allow = true;
                info-file = "/var/run/ioc/procServ_info";
              };
              type = with lib.types; attrsOf (oneOf [str int bool (listOf str)]);
              description = ''
                Extra command-line options to pass to procServ.

                Note: using `lib.mkForce` will override the default options needed
                for the systemd service to work. If you wish to do this, you will
                need to specify needed arguments like `foreground` and `chdir`.
              '';
            };
          };
        };

        config.procServ.options = {
          foreground = true;
          oneshot = true;
          logfile = "-";
          holdoff = 0;
          chdir = "${iocTop}/iocBoot/${config.ioc}";
        };

        config.config = {
          wantedBy = ["multi-user.target"];

          # When initializing the IOC, PV Access looks for network interfaces that
          # have IP addresses. "network.target" may be too early, especially for
          # systems with DHCP.
          wants = ["network-online.target"];
          after = ["network-online.target"];

          description = "EPICS IOC ${globalConfig.epnix.meta.name}";

          serviceConfig = {
            ExecStart = let
              procServ = "${pkgs.epnix.procServ}/bin/procServ";
              arch = epnix.lib.toEpicsArch globalConfig.epnix.outputs.build.stdenv.hostPlatform;
            in ''
              ${procServ} ${lib.cli.toGNUCommandLineShell {} config.procServ.options} \
              ${toString config.procServ.port} \
              ${iocTop}/bin/${arch}/${config.app} ${config.startCommandsFile}
            '';
            Restart = "on-failure";
          };
        };
      }));
    };
  };
}
