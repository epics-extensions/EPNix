{
  nixosTest,
  epnix,
  epnixLib,
  iocService,
  ...
}:
nixosTest {
  name = "simple";

  nodes.machine = {
    imports = [
      epnixLib.nixosModule

      # Import the IOC service,
      # as defined in flake.nix' nixosModules.iocService
      iocService
    ];

    environment.systemPackages = [ epnix.epics-base ];
  };

  testScript = ''
    machine.wait_for_unit("default.target")
    machine.wait_for_unit("myIoc.service")

    machine.wait_until_succeeds("caget stringin", timeout=10)
    machine.wait_until_succeeds("caget stringout", timeout=10)
    machine.fail("caget non-existing")

    with subtest("testing stringout"):
      def test_stringout(_) -> bool:
        machine.succeed("caput stringout 'hello'")
        status, _output = machine.execute("caget -t stringout | grep -qxF 'hello'")

        return status == 0

      retry(test_stringout)

      assert "hello" not in machine.succeed("caget -t stringin")
  '';
}
