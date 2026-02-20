# Using Python scripts

If you want to use Python packages in integration tests,
you can use Nix's `writePython3` functions:

```{code-block} nix
:caption: Define a Python script with dependencies

let
  myScript =
    pkgs.writers.writePython3 "myScript"
      {
        libraries = with pkgs.python3Packages; [
          p4p
          # Other packages...
        ];
      }
      ''
        # The actual Python script
        from p4p.nt import NTScalar
        from p4p.server import Server
        from p4p.server.thread import SharedPV

        pv = SharedPV(nt=NTScalar("d"), initial=0.0)

        ...

        Server.forever(providers=[{"demo:pv:name": pv}])
      '';
in ...
```

Two variants of this function exists:

`writePython3`
: Creates a Python script as a single file in {samp}`${out}`.

`writePython3Bin`
: Creates a Python script under {samp}`${out}/bin/${name}`.

## As an installed package

Since `writePython3Bin` creates a Python script under the `bin` folder,
it is more suited for installing packages
in the `environment.systemPackages` NixOS option:

```{code-block} nix
:caption: Installing a Python script as a package

{ lib, pkgs, ... }:
{
  nodes.machine = {
    environment.systemPackages = [
      (pkgs.writers.writePython3 "p4p-client"
        {
          libraries = [ pkgs.python3Packages.p4p ];
        }
        ''
          from p4p.client.thread import Context

          ctxt = Context('pva')
          v = ctxt.get('demo:pv:name')
        ''
      )
    ];
  };

  testScript = ''
    start_all()
    ...
    machine.succeed("p4p-client")
  '';
}
```

## Calling it in directly in test script

For calling the script directly,
`writePython3` is more direct to call than its `Bin` counterpart:

```{code-block} nix
:caption: Using a Python script directly in the test script

{ lib, pkgs, ... }:
{
  nodes.machine = {
    # ...
  };

  testScript =
    let
      p4p-client =
        pkgs.writers.writePython3 "p4p-client"
          {
            libraries = [ pkgs.python3Packages.p4p ];
          }
          ''
            from p4p.client.thread import Context

            ctxt = Context('pva')
            v = ctxt.get('demo:pv:name')
          '';
    in
    ''
      start_all()
      ...
      machine.succeed("${p4p-client}")
    '';
}
```

## As a systemd service

`writePython3` is again more direct to call than its `Bin` counterpart
and can be used directly as an `ExecStart=` argument:

```{code-block} nix
:caption: Using a Python script as a systemd service

{ lib, pkgs, ... }:
{
  nodes.machine = {
    systemd.services.p4p-server = {
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      serviceConfig.ExecStart =
        pkgs.writers.writePython3 "p4p-server" { libraries = [ pkgs.python3Packages.p4p ]; }
          ''
            from p4p.nt import NTScalar
            from p4p.server import Server
            from p4p.server.thread import SharedPV

            pv = SharedPV(nt=NTScalar("d"), initial=0.0)

            ...

            Server.forever(providers=[{"demo:pv:name": pv}])
          '';
    };
  };

  testScript = ''
    ...
  '';
}
```
