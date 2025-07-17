# Integration tests

::: {seealso}
For a more step-by-step tutorial on using integration tests,
follow the {doc}`../../tutorials/integration-tests` tutorial.
:::

::: {seealso}
The NixOS integration tests described here are documented in the [NixOS Tests] section
of the NixOS manual.
:::

## Pre-requisites

:::{warning}
When running tests,
Nix assumes you can run hardware-accelerated VMs,
through KVM.
:::

Make sure that you have KVM on your Linux machine
by checking if the file {file}`/dev/kvm` is present.

If the file is present,
you can proceed to the next section.

If you don't have KVM,
and you're running Nix on a physical machine,
examine your firmware settings
to see if you can enable hardware-accelerated virtualization.
The setting can show up as:

- Virtualization
- Intel Virtualization Technology
- Intel VT
- VT-d
- SVM Mode
- AMD-v

If you don't have KVM,
and you're running Nix on a virtual machine,
check your firmware settings
as said before,
and look up your hypervisor documentation
to enable nested virtualization.

If this doesn't work,
you can still proceed without hardware acceleration
by adding this line to your {file}`nix.conf`:

```{code-block} dosini
:caption: {file}`/etc/nix/nix.conf`

extra-system-features = kvm
```

Note that this means much slower integration tests.

## Integration tests location

The default EPNix template used to create an IOC
includes an integration test in {file}`checks/simple.nix`.

This check is imported in your {file}`flake.nix`,

:::{seealso}
See the {doc}`../../explanations/template-files` explanation
for more information about files found in the default EPNix template.
:::

## List available tests

To list what your top exposes,
including available tests,
run:

```{code-block} bash
:caption: Show exposed flake outputs

nix flake show
```

The tests are shown in the `checks` branch:

```{code-block} console
:caption: `nix flake show` --- example output
:emphasize-lines: 2-4

git+file:///home/...
├───checks
│   └───x86_64-linux
│       └───simple: derivation 'vm-test-run-simple'
├───formatter
│   └───x86_64-linux: package 'treefmt-for-epnix'
├───nixosModules
│   └───iocService: NixOS module
├───overlays
│   └───default: Nixpkgs overlay
└───packages
    └───x86_64-linux
        └───default: package 'myIoc-0.0.1'
```

## Running tests

To run all tests,
run:

```{code-block} bash
:caption: Run all integration tests

nix flake check -L
```

To run a specific test,
run:

```{code-block} bash
:caption: Running the test "simple"

nix build -L '.#checks.x86_64-linux.simple'
```

## Running tests interactively

To launch the VM interactively,
run:

```{code-block} bash
:caption: Running the test "simple" interactively

nix run -L '.#checks.x86_64-linux.simple.driverInteractive'
```

You can then run `start_all()` to start all VMs declared in the test.

:::{seealso}
For how to interact with the Python shell,
see {ref}`run-driverinteractive` in the integration test tutorial.
:::

## Adding a test

To add a test,
copy an existing test into another file in the {file}`checks/` folder:

```{code-block} bash
:caption: Copying a test

cp checks/simple.nix checks/my-new-check.nix
```

Then import it in your {file}`flake.nix`

```{code-block} nix
:caption: {file}`flake.nix` --- Importing a new check
:emphasize-lines: 7-9

  # ...

  checks = {
    simple = pkgs.callPackage ./checks/simple.nix {
      inherit (self.nixosModules) iocService;
    };
    my-new-check = pkgs.callPackage ./checks/my-new-check.nix {
      inherit (self.nixosModules) iocService;
    };
  };

  # ...
```

## Changing the test

The test is a Python script,
declared in the `testScript` attribute.

For a step-by-step example on how to write a test,
follow the {doc}`../../tutorials/integration-tests` tutorial.

For a complete list of Python functions available,
see the [NixOS Tests] documentation in the NixOS manual.

### Extracting the test in a separate file

To extract the test into a separate Python file,
create your {file}`checks/{simple}.py`,
with the Python content.

Then in your {file}`checks/{simple}.nix`,
set `testScript` as follows:

```{code-block} nix
:caption: {file}`checks/{simple}.nix` --- Extract the test script into a separate file

    testScript = builtins.readFile ./simple.py;
```

## Changing the VM configuration

The configuration inside each node inside `nodes` is a NixOS configuration.
You can change this configuration as any NixOS configuration.

:::{seealso}
- [Configuration Syntax] in the NixOS manual
- [NixOS options search]
:::

The following are a few pointers.

### Add a package

To add a package that can be used in the test script,
use the `environment.systemPackages` option.

For example:

```{code-block} nix
:caption: {file}`check/{simple}.nix` --- Adding the `openssh` package to the system
:emphasize-lines: 3,12

  # ...

  nodes.machine = { pkgs, ... }: {
    imports = [
      epnixLib.nixosModule

      # Import the IOC service,
      # as defined in flake.nix' nixosModules.iocService
      iocService
    ];

    environment.systemPackages = [ epnix.epics-base pkgs.openssh ];
  };

  # ...
```

### Changing the IOC integration

Changing how your IOC is integrated in the test VM
is the same as configuring your IOC in a NixOS system.

See the {doc}`../../../nixos-services/user-guides/ioc-services` NixOS guide
for how to integrate your IOC in NixOS.

### Adding another machine

To add another machine,
add another entry in `nodes`:

```{code-block} nix
:caption: {file}`checks/{simple}.nix` --- Adding another machine
:emphasize-lines: 7-10

  # ...

  nodes.machine = {
    # ...
  };

  # Adding another machine with openssh installed
  nodes.other-machine = {
    environment.systemPackages = [ pkgs.openssh ];
  };

  testScript = ''
    # ...
  '';

  # ...
```

  [Configuration Syntax]: https://nixos.org/manual/nixos/stable/#sec-configuration-syntax
  [NixOS Tests]: https://nixos.org/manual/nixos/stable/index.html#sec-nixos-tests
  [NixOS options search]: https://search.nixos.org/options
