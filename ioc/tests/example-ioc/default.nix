{pkgs, ...}: let
  inherit (pkgs) epnixLib;

  ioc = pkgs.callPackage ./ioc.nix {};
in {
  name = "example-ioc";
  meta.maintainers = with epnixLib.maintainers; [minijackson];

  nodes.machine = {
    environment.systemPackages = [pkgs.epnix.epics-base];

    services.iocs.ioc = {
      package = ioc;
      workingDirectory = "iocBoot/iocSimple";
    };
  };

  testScript = ''
    machine.wait_for_unit("default.target")
    machine.wait_for_unit("ioc.service")

    def logs_has(content: str) -> None:
      machine.wait_until_succeeds(f"journalctl --no-pager -u ioc.service | grep -F '{content}'")

    with subtest("wait until started"):
      machine.wait_until_succeeds("caget -t epnix:aiExample")

    with subtest("EPICS revision is correct"):
      logs_has("## EPICS R7")

    with subtest("ai/calc records"):
      ai_example = int(machine.wait_until_succeeds("caget -t epnix:aiExample").strip())
      assert 0 <= ai_example <= 9

    with subtest("version record"):
      assert machine.succeed("caget -t epnix:simple:version").strip() == "EPNix"

    with subtest("aSub record"):
      logs_has("Record epnix:aSubExample called myAsubInit")
      logs_has("Record epnix:aSubExample called myAsubProcess")

    # Also needs the debug mode activated above
    with subtest("sub record"):
      logs_has("Record epnix:subExample called mySubInit")
      machine.succeed("caput epnix:subExample 42")
      logs_has("Record epnix:subExample called mySubProcess")

    with subtest("Sequencer program is running"):
      logs_has("sncExample: Startup delay over")
      logs_has("sncExample: Changing to")

    with subtest("Sequencer program is running"):
      machine.succeed("echo 'hello world' | nc localhost 2000 -N")
      logs_has("Hello world, from simple")

    # TODO: test QSRV, but it feels flaky, pvget times-out most of the time
  '';

  passthru = {
    inherit ioc;
  };
}
