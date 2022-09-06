{
  build,
  pkgs,
  ...
}:
pkgs.nixosTest {
  name = "simple";

  nodes.machine = {
    environment.systemPackages = [pkgs.epnix.epics-base];

    systemd.services.my-ioc = {
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        ExecStart = "${build}/iocBoot/iocexample/st.cmd";
        WorkingDirectory = "${build}/iocBoot/iocexample";
        StandardInputText = "epicsThreadSleep(100)";
      };
    };
  };

  testScript = ''
    start_all()

    machine.wait_for_unit("default.target")
    machine.wait_for_unit("my-ioc.service")

    machine.wait_until_succeeds("caget stringin")
    machine.wait_until_succeeds("caget stringout")
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
