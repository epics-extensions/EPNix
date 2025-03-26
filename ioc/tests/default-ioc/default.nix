{
  pkgs,
  releaseBranch,
  ...
}: let
  inherit (pkgs) epnixLib;

  ioc = pkgs.callPackage ./ioc.nix {inherit releaseBranch;};
in {
  name = "default-ioc-epics-base-${releaseBranch}";
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

    with subtest("wait until started"):
      assert machine.wait_until_succeeds("caget -t SIMPLE:AI").strip() == "0"

    with subtest("EPICS revision is correct"):
      machine.succeed("journalctl --no-pager -u ioc.service | grep -F '## EPICS R${releaseBranch}'")

    with subtest("ai records"):
      assert machine.wait_until_succeeds("caget -t SIMPLE:AI").strip() == "0"
      machine.succeed("caput SIMPLE:AI 123.456")
      assert machine.wait_until_succeeds("caget -t SIMPLE:AI").strip() == "123.456"
  '';

  passthru = {
    inherit ioc;
  };
}
