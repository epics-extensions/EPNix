{
  config,
  epnix,
  lib,
  pkgs,
  ...
}: let
  cfg = config.epnix.nixos;

  iocTop = "${config.epnix.outputs.build}";
in {
  options.epnix.nixos = {
    service = {
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
  };

  config.epnix.nixos.service.procServ.options = {
    foreground = true;
    oneshot = true;
    logfile = "-";
    chdir = "${iocTop}/iocBoot/${cfg.service.ioc}";
  };

  config.epnix.nixos.service.config = {
    wantedBy = ["multi-user.target"];
    after = ["network.target"];

    description = "EPICS IOC ${config.epnix.meta.name}";

    serviceConfig = {
      ExecStart = let
        procServ = "${pkgs.epnix.procServ}/bin/procServ";
        arch = epnix.lib.toEpicsArch config.epnix.outputs.build.stdenv.hostPlatform;
      in ''
        ${procServ} ${lib.cli.toGNUCommandLineShell {} cfg.service.procServ.options} \
        ${toString cfg.service.procServ.port} \
        ${iocTop}/bin/${arch}/${cfg.service.app} ${cfg.service.startCommandsFile}
      '';
      Restart = "on-failure";
    };
  };
}
