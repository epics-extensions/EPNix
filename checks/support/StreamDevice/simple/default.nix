{pkgs, ...}: let
  inherit (pkgs) epnixLib;
  inherit (pkgs.stdenv.hostPlatform) system;

  mock_server = pkgs.poetry2nix.mkPoetryApplication {
    projectDir = ./mock-server;
  };

  ioc = epnixLib.mkEpnixBuild {
    nixpkgsConfig.system = system;
    epnixConfig.imports = [./top/epnix.nix];
  };
in
  pkgs.nixosTest {
    name = "support-StreamDevice-simple";
    meta.maintainers = with epnixLib.maintainers; [minijackson];

    nodes.machine = let
      listenAddr = "127.0.0.1:1234";
    in {
      environment.systemPackages = [pkgs.epnix.epics-base];

      systemd.sockets.mock-server = {
        wantedBy = ["multi-user.target"];
        listenStreams = [listenAddr];
        socketConfig.Accept = true;
      };

      systemd.services = {
        "mock-server@".serviceConfig = {
          ExecStart = "${mock_server}/bin/mock_server";
          StandardInput = "socket";
          StandardError = "journal";
        };

        ioc = {
          wantedBy = ["multi-user.target"];

          environment.STREAM_PS1 = listenAddr;

          serviceConfig = {
            ExecStart = "${ioc}/iocBoot/iocsimple/st.cmd";
            Type = "notify";
            WorkingDirectory = "${ioc}/iocBoot/iocsimple";
            # TODO: this is hacky, find a way to have EPICS keep going without
            # a shell
            StandardInputText = "epicsThreadSleep(100)";
          };
        };
      };
    };

    testScript = ''
      start_all()

      machine.wait_for_unit("default.target")
      machine.wait_for_unit("ioc.service")

      with subtest("getting fixed values"):
        machine.wait_until_succeeds("caget -t FLOAT:IN | grep -qxF '42.1234'")
        machine.wait_until_succeeds("caget -t FLOAT_WITH_PREFIX:IN | grep -qxF '69.1337'")
        machine.wait_until_succeeds("caget -t ENUM:IN | grep -qxF '1'")

      with subtest("setting values"):
        machine.wait_until_succeeds("caget -t VARFLOAT:IN | grep -qxF '0'")

        # Caput can simply not go through
        def put_check_varfloat(_) -> bool:
          machine.succeed("caput VARFLOAT:OUT 123.456")
          status, _output = machine.execute("caget -t VARFLOAT:IN | grep -qxF '123.456'")
          return status == 0

        retry(put_check_varfloat)

      with subtest("calc integration"):
        machine.wait_until_succeeds("caget -t SCALC:IN | grep -qxF '10A'")

        def put_check_scalc(_) -> bool:
          machine.succeed("caput SCALC:OUT.A 2")
          status, _output = machine.execute("caget -t SCALC:IN | grep -qxF '14A'")
          return status == 0

        retry(put_check_scalc)

        machine.wait_until_succeeds("caget -t SCALC:OUT.SVAL | grep -qxF 'sent'")

      with subtest("regular expressions"):
        machine.wait_until_succeeds("caget -t REGEX_TITLE:IN | grep -qxF 'Hello, World!'")
        machine.wait_until_succeeds("caget -t REGEX_SUB:IN | grep -qxF 'abcXcXcabc'")
    '';

    passthru = {
      inherit mock_server ioc;
    };
  }
