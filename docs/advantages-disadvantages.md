# Advantages / disadvantages

## Advantages

Leveraging the Nix package manager offers several advantages
compared to packaging EPICS in the traditional way.

Some of these advantages are explained on the [NixOS website].

### Complete dependencies

Your EPICS application includes the complete set of dependencies,
enabling you to deploy your application
without needing to install any dependencies
on the target machine (except Nix itself).

### Locked dependencies

The versions of your dependencies are locked,
updated manually,
and tracked in your `flake.lock` file.

Combined with code versioning,
this lets you build your project in the same environment
even years later.

You can also use this feature
to roll back to any earlier version.

### Dependency traceability

You can identify the exact version
of each of your build-time or runtime dependencies.
This can be useful
for complying with supply chain security requirements.

### Development shell

You have access to a set of tools tailored to your project,
regardless of what's installed on your machine.

### Declarative configurations

Nix serves as a declarative language
for specifying what you want in your application,
your development shell,
or how to configure a NixOS Linux system.

### Integration tests

You can write tests by using the NixOS test framework,
which launches clusters of NixOS virtual machines
containing the applications you want to test.
These machines are controllable and testable through a Python API.

### Offline deployments

NixOS enables you to deploy to machines
that don't have a global internet connection.

### Vendor-agnostic continuous integration

Because Nix handles dependencies and building,
most CI actions follow a two-step process:

-   installing Nix in the CI
-   running the `nix build` or `nix run` command

This lets you run CI actions locally
on any developer machine.
It also makes it easier to migrate to a different CI system
if needed.

### Distributed builds

Nix can build packages on many remote machines.
See the Nix.dev documentation on [Remote builds] for more information.

### Cache server

You can deploy a Nix cache server in your infrastructure,
enabling users to download pre-built versions of any software packaged with Nix
without needing to compile them.

## Disadvantages

### Nix learning curve

Nix is known for its steep learning curve
and uneven documentation.

Be sure to experiment with the Nix ecosystem
before deploying Nix-based packages into production.

You can use EPNix for non-critical tasks
such as:

-   defining development shells
-   quickly running a package,
    for example Phoebus or a `softIoc`
-   running tests

### Strict packaging

Nix is strict about packaging software.
Most Nix builds occur in a sandbox
with only the specified dependencies
and no internet access.

Nix also assumes that builds are reproducible
(see [Reproducible builds]).

This strictness enables many of Nix's features,
but it also means some software is more difficult to package than others.

### Non-uniformity

Depending on how you declare your IOCs and NixOS machines,
your deployments might have different versions of software dependencies.

For example,
different deployed IOCs can use different versions of StreamDevice or asyn.
This is technically acceptable
if the EPICS Channel Access or PV Access protocol remains compatible with earlier versions.

For deployments such as Phoebus services
or Archiver Appliance,
which use HTTP APIs,
it is your responsibility to design your Nix and NixOS deployments
so that the set of deployed software remains compatible across installations.

  [NixOS website]: https://nixos.org/
  [Reproducible builds]: https://reproducible-builds.org/
  [Remote builds]: https://nix.dev/manual/nix/stable/advanced-topics/distributed-builds
