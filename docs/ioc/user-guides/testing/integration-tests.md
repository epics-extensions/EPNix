# Integration tests

::: {seealso}
For a more step-by-step tutorial on using integration tests,
follow the {doc}`../../tutorials/integration-tests` tutorial.
:::

::: {seealso}
The NixOS integration tests described here are documented in the [NixOS Tests] section
of the NixOS manual.
:::

## Prerequisites

:::{warning}
When running tests,
Nix assumes you can run hardware-accelerated VMs using KVM.
:::

Ensure that KVM is available on your Linux machine
by checking whether the file {file}`/dev/kvm` exists.

If the file is present,
you can proceed to the next section.

If you don't have KVM
and are running Nix on a physical machine,
inspect your firmware settings
to see if you can enable hardware-accelerated virtualization.
The setting might appear as:

- Virtualization
- Intel Virtualization Technology
- Intel VT
- VT-d
- SVM Mode
- AMD-v

If you don't have KVM
and are running Nix on a virtual machine,
review your firmware settings
as described earlier,
and consult your hypervisor documentation
to enable nested virtualization.

If this isn't possible,
you can still proceed without hardware acceleration
by adding the following line to your {file}`nix.conf`:

```{code-block} dosini
:caption: {file}`/etc/nix/nix.conf`

extra-system-features = kvm
```

Note that integration tests run much more slowly
without hardware acceleration.

## Integration tests location

The default EPNix template used to create an IOC
includes an integration test in {file}`checks/simple.nix`.

This check is imported in your {file}`flake.nix`,

:::{seealso}
See the {doc}`../../explanations/template-files` explanation
for more information about files included in the default EPNix template.
:::

## Listing available tests

To view what your flake exposes,
including available tests,
run:

```{code-block} bash
:caption: Showing exposed flake outputs

nix flake show
```

Tests are displayed in the `checks` branch:

```{code-block} console
:caption: `nix flake show` --- Example output
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
:caption: Running all integration tests

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

You can then run `start_all()` to start all VMs defined in the test.

:::{seealso}
For information about interacting with the Python shell,
see {ref}`run-driverinteractive` in the integration test tutorial.
:::

## Adding a test

To add a new test,
copy an existing test into another file in the {file}`checks/` folder:

```{code-block} bash
:caption: Copying a test

cp checks/simple.nix checks/my-new-check.nix
```

Then import it in your {file}`flake.nix`:

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

## Changing the test script

The test script is declared in the `testScript` attribute,
in Python.

:::{seealso}
For a step-by-step example on how to write a test script,
follow the {doc}`../../tutorials/integration-tests` tutorial.
:::

:::{seealso}
For a complete list of available Python functions,
see the [NixOS Tests] documentation in the NixOS manual.
:::

### Extracting the test into a separate file

To extract the test into a separate Python file,
create your {file}`checks/{simple}.py`,
with the Python code.

Then, in your {file}`checks/{simple}.nix`,
set `testScript` as follows:

```{code-block} nix
:caption: {file}`checks/{simple}.nix` --- Extracting the test script into a separate file

    testScript = builtins.readFile ./simple.py;
```

## Changing the VM configuration

Each node listed under `nodes` is a NixOS configuration.
You can edit these configurations as you would any NixOS configuration.

:::{seealso}
- [Configuration Syntax] in the NixOS manual
- [NixOS options search]
:::

The following are a some pointers.

### Adding a package

To add a package for use in the test script,
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
      # as defined in flake.nix's nixosModules.iocService
      iocService
    ];

    environment.systemPackages = [ epnix.epics-base pkgs.openssh ];
  };

  # ...
```

### Changing the IOC integration

To change how your IOC is integrated into the test VM,
configure it as you would for any NixOS system.

See the {doc}`../../../nixos-services/user-guides/ioc-services` NixOS guide
for instructions on integrating your IOC in NixOS.

### Adding another machine

To add another machine,
add another entry under `nodes`:

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
